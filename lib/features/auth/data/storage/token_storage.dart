import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memilogistics_app/core/secure_storage/secure_storage_service.dart';

import 'package:memilogistics_app/shared/storage_exception.dart';

class TokenStorage {
  final FlutterSecureStorage storage;

  static const _legacyAccessTokenKey = 'access_token';
  static const _legacyRefreshTokenKey = 'refresh_token';

  TokenStorage({required this.storage});

  /// Save tokens
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await storage.write(key: StorageKeys.accessToken, value: accessToken);

      if (refreshToken != null) {
        await storage.write(key: StorageKeys.refreshToken, value: refreshToken);
      }
    } catch (e) {
      throw StorageException('Failed to save tokens');
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: StorageKeys.accessToken) ??
          storage.read(key: _legacyAccessTokenKey);
    } catch (e) {
      throw StorageException('Failed to read access token');
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(key: StorageKeys.refreshToken) ??
          storage.read(key: _legacyRefreshTokenKey);
    } catch (e) {
      throw StorageException('Failed to read refresh token');
    }
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        storage.delete(key: StorageKeys.accessToken),
        storage.delete(key: StorageKeys.refreshToken),
        storage.delete(key: StorageKeys.accessTokenExpiry),
        storage.delete(key: StorageKeys.refreshTokenExpiry),
        storage.delete(key: _legacyAccessTokenKey),
        storage.delete(key: _legacyRefreshTokenKey),
      ]);
    } catch (e) {
      throw StorageException('Failed to clear tokens');
    }
  }

  /// Check if user is logged in
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
