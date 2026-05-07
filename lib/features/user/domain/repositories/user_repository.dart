// lib/features/user/domain/repositories/user_repository.dart

import '../entities/current_user.dart';
import '../entities/user_profile.dart';
import '../entities/user_permission.dart';

abstract class UserRepository {
  Future<CurrentUser> getCurrentUser();
  
  Future<UserProfile> getUserProfile(String userId);
  
  Future<UserProfile> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  });
  
  Future<List<UserPermission>> getPermissions(String userId);
  
  Future<void> updateAvatar({
    required String userId,
    required String avatarUrl,
  });
}
