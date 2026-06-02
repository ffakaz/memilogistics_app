import 'package:memilogistics_app/core/secure_storage/secure_storage_service.dart';
import 'package:memilogistics_app/shared/storage_exception.dart';
import 'package:memilogistics_app/core/error/exceptions.dart';

class TokenStorage {
  final SecureStorageService storage;

  TokenStorage({required this.storage});

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? role,
  }) async {
    try {
      await storage.write(key: StorageKeys.accessToken, value: accessToken);
      if (refreshToken != null) {
        await storage.write(key: StorageKeys.refreshToken, value: refreshToken);
      }
      if (role != null) {
        await storage.write(
          key: StorageKeys.userRole,
          value: role.trim().toUpperCase(),
        );
      }
    } catch (e) {
      throw StorageException('Failed to save tokens: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await storage.read(StorageKeys.accessToken);
    } catch (e) {
      throw StorageException('Failed to read access token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(StorageKeys.refreshToken);
    } catch (e) {
      throw StorageException('Failed to read refresh token: $e');
    }
  }

  Future<String?> getUserRole() async {
    try {
      return await storage.read(StorageKeys.userRole);
    } catch (e) {
      throw StorageException('Failed to read user role: $e');
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        storage.delete(StorageKeys.accessToken),
        storage.delete(StorageKeys.refreshToken),
        storage.delete(StorageKeys.accessTokenExpiry),
        storage.delete(StorageKeys.refreshTokenExpiry),
        storage.delete(StorageKeys.userRole),
      ]);
    } catch (e) {
      throw StorageException('Failed to clear tokens: $e');
    }
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
