// lib/features/user/data/services/user_api_service.dart

import 'package:memilogistics_app/core/core.dart';

class UserApiService {
  final ApiClient _apiClient;

  UserApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/user/me',
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to get current user');
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/user/$userId',
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to get user profile');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/user/$userId',
      data: updates,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to update profile');
    }
  }

  Future<List<Map<String, dynamic>>> getPermissions(String userId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/user/$userId/permissions',
    );

    if (response.isSuccess && response.data != null) {
      final permissions = response.data!['permissions'] as List<dynamic>?;
      return permissions?.cast<Map<String, dynamic>>() ?? [];
    } else {
      throw Exception(response.message ?? 'Failed to get permissions');
    }
  }

  Future<void> updateAvatar({
    required String userId,
    required String avatarUrl,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/user/$userId/avatar',
      data: {'avatar_url': avatarUrl},
    );

    if (!response.isSuccess) {
      throw Exception(response.message ?? 'Failed to update avatar');
    }
  }
}
