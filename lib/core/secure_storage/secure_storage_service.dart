import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memilogistics_app/core/error/exceptions.dart';

/// ── Storage Keys ─────────────────────────────────────────────────────────
/// Keep all keys here to avoid duplication and collisions.
abstract class StorageKeys {
  StorageKeys._();

  // Auth
  static const String accessToken = 'auth.access_token';
  static const String refreshToken = 'auth.refresh_token';
  static const String accessTokenExpiry = 'auth.access_token_expiry_ms';
  static const String refreshTokenExpiry = 'auth.refresh_token_expiry_ms';
  static const String cachedUserJson = 'auth.cached_user_json';
}

/// Exceptions are re-used from `core/error/exceptions.dart` to avoid
/// duplicate type declarations when exporting `core` barrel files.

/// ── Service ─────────────────────────────────────────────────────────────
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // Platform-specific options
  static const _android = AndroidOptions(encryptedSharedPreferences: true);
  static const _ios = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  // ── Generic CRUD ───────────────────────────────────────────────────────

  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        aOptions: _android,
        iOptions: _ios,
      );
    } catch (e) {
      throw StorageException('Write failed for "$key": $e');
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(
        key: key,
        aOptions: _android,
        iOptions: _ios,
      );
    } catch (e) {
      throw StorageException('Read failed for "$key": $e');
    }
  }

  Future<String> readOrThrow(String key) async {
    final value = await read(key);
    if (value == null) {
      throw CacheNotFoundException('No value stored for "$key"');
    }
    return value;
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(
        key: key,
        aOptions: _android,
        iOptions: _ios,
      );
    } catch (e) {
      throw StorageException('Delete failed for "$key": $e');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll(
        aOptions: _android,
        iOptions: _ios,
      );
    } catch (e) {
      throw StorageException('deleteAll failed: $e');
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(
        key: key,
        aOptions: _android,
        iOptions: _ios,
      );
    } catch (e) {
      throw StorageException('containsKey failed for "$key": $e');
    }
  }

  // ── JSON Helpers ───────────────────────────────────────────────────────

  Future<void> writeJson({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    await write(key: key, value: jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    final data = await read(key);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // ── Auth Helpers (keep for now, can be extracted later) ─────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiresAt,
    required DateTime refreshTokenExpiresAt,
  }) async {
    await Future.wait([
      write(key: StorageKeys.accessToken, value: accessToken),
      write(key: StorageKeys.refreshToken, value: refreshToken),
      write(
        key: StorageKeys.accessTokenExpiry,
        value: accessTokenExpiresAt.millisecondsSinceEpoch.toString(),
      ),
      write(
        key: StorageKeys.refreshTokenExpiry,
        value: refreshTokenExpiresAt.millisecondsSinceEpoch.toString(),
      ),
    ]);
  }

  Future<String?> getAccessToken() => read(StorageKeys.accessToken);

  Future<String?> getRefreshToken() => read(StorageKeys.refreshToken);

  Future<bool> hasValidSession() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final expiryStr = await read(StorageKeys.refreshTokenExpiry);
      final expiry = int.tryParse(expiryStr ?? '');

      return !_isExpired(expiry);
    } catch (_) {
      return false;
    }
  }

  bool _isExpired(int? expiryMillis) {
    if (expiryMillis == null) return true;
    return DateTime.now().millisecondsSinceEpoch >= expiryMillis;
  }

  Future<void> clearAuthData() async {
    await Future.wait([
      delete(StorageKeys.accessToken),
      delete(StorageKeys.refreshToken),
      delete(StorageKeys.accessTokenExpiry),
      delete(StorageKeys.refreshTokenExpiry),
      delete(StorageKeys.cachedUserJson),
    ]);
  }
}