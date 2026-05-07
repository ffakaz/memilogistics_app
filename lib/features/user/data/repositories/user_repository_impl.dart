// lib/features/user/data/repositories/user_repository_impl.dart

import '../../domain/entities/current_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_permission.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/current_user_model.dart';
import '../models/user_profile_model.dart';
import '../models/permission_model.dart';
import '../services/user_api_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApiService apiService;

  UserRepositoryImpl({required this.apiService});

  @override
  Future<CurrentUser> getCurrentUser() async {
    try {
      final json = await apiService.getCurrentUser();
      final model = CurrentUserModel.fromJson(json);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final json = await apiService.getUserProfile(userId);
      final model = UserProfileModel.fromJson(json);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final json = await apiService.updateProfile(
        userId: userId,
        updates: updates,
      );
      final model = UserProfileModel.fromJson(json);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<List<UserPermission>> getPermissions(String userId) async {
    try {
      final jsonList = await apiService.getPermissions(userId);
      return jsonList
          .map((json) => PermissionModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get permissions: $e');
    }
  }

  @override
  Future<void> updateAvatar({
    required String userId,
    required String avatarUrl,
  }) async {
    try {
      await apiService.updateAvatar(
        userId: userId,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      throw Exception('Failed to update avatar: $e');
    }
  }
}
