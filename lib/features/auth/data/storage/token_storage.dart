import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:memilogistics_app/shared/storage_exception.dart';

class TokenStorage {
  final FlutterSecureStorage storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  TokenStorage({required this.storage});

  /// Save tokens
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await storage.write(key: _accessTokenKey, value: accessToken);

      if (refreshToken != null) {
        await storage.write(key: _refreshTokenKey, value: refreshToken);
      }
    } catch (e) {
      throw StorageException('Failed to save tokens');
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: _accessTokenKey);
    } catch (e) {
      throw StorageException('Failed to read access token');
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw StorageException('Failed to read refresh token');
    }
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    try {
      await storage.delete(key: _accessTokenKey);
      await storage.delete(key: _refreshTokenKey);
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