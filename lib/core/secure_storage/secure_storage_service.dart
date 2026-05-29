import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  static const String userRole = 'auth.user_role'; // User role: SHIPPER or CARRIER
}

/// Exceptions are re-used from `core/error/exceptions.dart` to avoid
/// duplicate type declarations when exporting `core` barrel files.

/// ── Service ─────────────────────────────────────────────────────────────
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _memoryCache = {}; // In-memory fallback for web

  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryCache; // Fallback cache for web

  // Platform-specific options - ONLY for mobile/desktop platforms
  static const _android = AndroidOptions(encryptedSharedPreferences: true);
  static const _ios = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  /// Check if we're running on web platform
  bool get _isWeb => kIsWeb;

  // ── Generic CRUD ───────────────────────────────────────────────────────

  Future<void> write({required String key, required String value}) async {
    try {
      if (_isWeb) {
        // On web, use in-memory cache (persisted by flutter_secure_storage_web via JS localStorage)
        _memoryCache[key] = value;
      }
      
      await _storage.write(
        key: key,
        value: value,
        aOptions: _isWeb ? null : _android,
        iOptions: _isWeb ? null : _ios,
      );
      
      if (_isWeb) {
        // DEBUG: Log web storage operations
        print('🌐 [SecureStorage] Web write: $key');
      }
    } catch (e) {
      // On web, if official secure storage fails, keep in-memory cache
      if (_isWeb) {
        _memoryCache[key] = value;
        print('⚠️  [SecureStorage] Web write failed, using memory cache: $key - $e');
      } else {
        throw StorageException('Write failed for "$key": $e');
      }
    }
  }

  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(
        key: key,
        aOptions: _isWeb ? null : _android,
        iOptions: _isWeb ? null : _ios,
      );
      
      if (_isWeb && value == null) {
        // Try memory cache if actual storage failed
        return _memoryCache[key];
      }
      
      if (_isWeb && value != null) {
        print('🌐 [SecureStorage] Web read: $key');
      }
      
      return value;
    } catch (e) {
      // On web, fallback to memory cache
      if (_isWeb) {
        final cached = _memoryCache[key];
        if (cached != null) {
          print('⚠️  [SecureStorage] Web read failed, using memory cache: $key');
          return cached;
        }
        return null; // Silent fail on web
      }
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
      if (_isWeb) {
        _memoryCache.remove(key);
      }
      
      await _storage.delete(
        key: key,
        aOptions: _isWeb ? null : _android,
        iOptions: _isWeb ? null : _ios,
      );
    } catch (e) {
      // On web, just remove from memory cache
      if (_isWeb) {
        _memoryCache.remove(key);
        print('⚠️  [SecureStorage] Web delete failed, removed from memory: $key');
      } else {
        throw StorageException('Delete failed for "$key": $e');
      }
    }
  }

  Future<void> deleteAll() async {
    try {
      if (_isWeb) {
        _memoryCache.clear();
      }
      
      await _storage.deleteAll(
        aOptions: _isWeb ? null : _android,
        iOptions: _isWeb ? null : _ios,
      );
    } catch (e) {
      // On web, just clear memory cache
      if (_isWeb) {
        _memoryCache.clear();
        print('⚠️  [SecureStorage] Web deleteAll failed, cleared memory cache');
      } else {
        throw StorageException('deleteAll failed: $e');
      }
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      final exists = await _storage.containsKey(
        key: key,
        aOptions: _isWeb ? null : _android,
        iOptions: _isWeb ? null : _ios,
      );
      
      // On web, also check memory cache
      if (_isWeb && !exists) {
        return _memoryCache.containsKey(key);
      }
      
      return exists;
    } catch (e) {
      // On web, fallback to memory cache check
      if (_isWeb) {
        return _memoryCache.containsKey(key);
      }
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

  Future<String?> getUserRole() => read(StorageKeys.userRole);

  Future<void> saveUserRole(String role) => write(key: StorageKeys.userRole, value: role);

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
      delete(StorageKeys.userRole),
    ]);
  }
}