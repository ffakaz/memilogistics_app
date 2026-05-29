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
    String refreshPath = '/api/auth/refresh',
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
        print('✅ [AuthInterceptor] Token attached to request: ${token.substring(0, 20)}...');
      } else {
        print('⚠️  [AuthInterceptor] No token found in storage');
      }
    } catch (e) {
      // No token stored; let request proceed unauthenticated.
      print('❌ [AuthInterceptor] Failed to retrieve token: $e');
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

    print('🔴 [AuthInterceptor] Error: ${err.requestOptions.path}');
    print('   Status: ${err.response?.statusCode}');
    print('   Is401: $is401, Skip: $skip, IsRetry: $isRetry');

    if (!is401 || skip || isRetry) return handler.next(err);

    // ── Queue if refresh already running ────────────────────────────────────
    if (_refreshing) {
      print('⏳ [AuthInterceptor] Refresh already running, queuing request...');
      final q = _Queued(err.requestOptions);
      _queue.add(q);
      try {
        final token = await q.future;
        print('✅ [AuthInterceptor] Retrying queued request with new token');
        handler.resolve(await _retry(err.requestOptions, token));
      } catch (_) {
        print('❌ [AuthInterceptor] Queued retry failed');
        handler.next(err);
      }
      return;
    }

    // ── Start refresh cycle ─────────────────────────────────────────────────
    print('🔄 [AuthInterceptor] Starting token refresh...');
    _refreshing = true;
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ [AuthInterceptor] No refresh token available');
        throw MissingTokenException();
      }

      print('📤 [AuthInterceptor] Sending refresh request...');
      final resp = await _dio.post<Map<String, dynamic>>(
        _refreshPath,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {_kSkipAuth: true}),
      );

      final data = resp.data!;
      print('✅ [AuthInterceptor] Refresh successful');
      // ── Adjust keys to match your Spring Boot token response ───────────────
      final newAccess = data['access_token'] as String? ??
          data['accessToken'] as String;
      final newRefresh = data['refresh_token'] as String? ??
          data['refreshToken'] as String;
      final expiry = _parseExpiry(data['expiry'] ?? data['accessTokenExpiresAt']);

      print('💾 [AuthInterceptor] Saving new tokens...');
      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
        accessTokenExpiresAt: expiry,
        refreshTokenExpiresAt:
            DateTime.now().add(const Duration(days: 30)), // adjust to backend
      );
      print('✅ [AuthInterceptor] Tokens saved successfully');

      // Retry original + all queued
      _resolveQueue(newAccess);
      handler.resolve(await _retry(err.requestOptions, newAccess));
    } catch (e) {
      print('❌ [AuthInterceptor] Refresh failed: $e');
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
    final safeHeaders = <String, dynamic>{};
    try {
      safeHeaders.addAll(Map<String, dynamic>.from(orig.headers));
    } catch (_) {}
    safeHeaders['Authorization'] = 'Bearer $token';

    final safeExtra = <String, dynamic>{};
    try {
      safeExtra.addAll(Map<String, dynamic>.from(orig.extra as Map));
    } catch (_) {}
    safeExtra[_kIsRetry] = true;

    return _dio.request<dynamic>(
      orig.path,
      data: orig.data,
      queryParameters: orig.queryParameters,
      options: Options(
        method: orig.method,
        headers: safeHeaders,
        contentType: orig.contentType,
        responseType: orig.responseType,
        extra: safeExtra,
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
