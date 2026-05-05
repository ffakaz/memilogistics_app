// lib/core/network/dio_interceptor.dart
//
// Handles the full JWT lifecycle for every Dio request:
//
//   REQUEST  → attach "Authorization: Bearer <accessToken>" header
//   ERROR    → on 401: refresh token → retry original request
//              → if refresh fails: clear storage → call onSessionExpired()
//
// Queue mechanism: while a refresh is in-flight, every concurrent 401
// waits in _queue. They all resume with the new token once refresh succeeds,
// or all fail if it doesn't. This prevents duplicate refresh calls.

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:memilogistics_app/core/core.dart';

/// Mark a request so the interceptor skips auth injection and refresh loops.
const _kSkipAuth = 'skipAuthInterceptor';

/// Mark retried requests so they don't trigger a second refresh cycle.
const _kIsRetry = '_isRetry';

class _Queued {
  _Queued(this.options) : _c = Completer<String>();
  final RequestOptions options;
  final Completer<String> _c;
  Future<String> get future => _c.future;
  void resolve(String t) => _c.complete(t);
  void reject(Object e) => _c.completeError(e);
}

class AuthDioInterceptor extends Interceptor {
  AuthDioInterceptor({
    required Dio dio,
    required SecureStorageService storage,
    required void Function() onSessionExpired,
    // Endpoint used for token refresh — override if your backend differs
    String refreshPath = '/api/v1/auth/refresh',
  })  : _dio = dio,
        _storage = storage,
        _onSessionExpired = onSessionExpired,
        _refreshPath = refreshPath;

  final Dio _dio;
  final SecureStorageService _storage;
  final void Function() _onSessionExpired;
  final String _refreshPath;

  bool _refreshing = false;
  final List<_Queued> _queue = [];

  // ── REQUEST ──────────────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[_kSkipAuth] == true) return handler.next(options);

    try {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // No token stored; let request proceed unauthenticated.
    }
    handler.next(options);
  }

  // ── RESPONSE ─────────────────────────────────────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) =>
      handler.next(response);

  // ── ERROR (401 handling) ─────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final skip = err.requestOptions.extra[_kSkipAuth] == true;
    final isRetry = err.requestOptions.extra[_kIsRetry] == true;

    if (!is401 || skip || isRetry) return handler.next(err);

    // ── Queue if refresh already running ────────────────────────────────────
    if (_refreshing) {
      final q = _Queued(err.requestOptions);
      _queue.add(q);
      try {
        final token = await q.future;
        handler.resolve(await _retry(err.requestOptions, token));
      } catch (_) {
        handler.next(err);
      }
      return;
    }

    // ── Start refresh cycle ─────────────────────────────────────────────────
    _refreshing = true;
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw MissingTokenException();
      }

      final resp = await _dio.post<Map<String, dynamic>>(
        _refreshPath,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {_kSkipAuth: true}),
      );

      final data = resp.data!;
      // ── Adjust keys to match your Spring Boot token response ───────────────
      final newAccess = data['access_token'] as String? ??
          data['accessToken'] as String;
      final newRefresh = data['refresh_token'] as String? ??
          data['refreshToken'] as String;
      final expiry = _parseExpiry(data['expiry'] ?? data['accessTokenExpiresAt']);

      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
        accessTokenExpiresAt: expiry,
        refreshTokenExpiresAt:
            DateTime.now().add(const Duration(days: 30)), // adjust to backend
      );

      // Retry original + all queued
      _resolveQueue(newAccess);
      handler.resolve(await _retry(err.requestOptions, newAccess));
    } catch (e) {
      await _storage.clearAuthData();
      _rejectQueue(e);
      _onSessionExpired();
      handler.next(err);
    } finally {
      _refreshing = false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<Response<dynamic>> _retry(RequestOptions orig, String token) {
    return _dio.request<dynamic>(
      orig.path,
      data: orig.data,
      queryParameters: orig.queryParameters,
      options: Options(
        method: orig.method,
        headers: {...orig.headers, 'Authorization': 'Bearer $token'},
        contentType: orig.contentType,
        responseType: orig.responseType,
        extra: {...orig.extra, _kIsRetry: true},
      ),
    );
  }

  void _resolveQueue(String token) {
    for (final q in _queue) {
      q.resolve(token);
    }
    _queue.clear();
  }

  void _rejectQueue(Object e) {
    for (final q in _queue) {
      q.reject(e);
    }
    _queue.clear();
  }

  static DateTime _parseExpiry(dynamic v) {
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
    }
    // Safe fallback — treat as already expired
    return DateTime.now().subtract(const Duration(seconds: 1));
  }
}