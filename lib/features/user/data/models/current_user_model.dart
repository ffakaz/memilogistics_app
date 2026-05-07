// lib/features/user/data/models/current_user_model.dart

import '../../domain/entities/current_user.dart';
import 'user_profile_model.dart';
import 'permission_model.dart';

class CurrentUserModel {
  final UserProfileModel profile;
  final List<PermissionModel> permissions;
  final String? accessToken;
  final String? lastLogin;

  const CurrentUserModel({
    required this.profile,
    required this.permissions,
    this.accessToken,
    this.lastLogin,
  });

  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserModel(
      profile: UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>? ?? {}),
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => PermissionModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      accessToken: json['access_token'] as String?,
      lastLogin: json['last_login'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': profile.toJson(),
      'permissions': permissions.map((p) => p.toJson()).toList(),
      'access_token': accessToken,
      'last_login': lastLogin,
    };
  }

  CurrentUser toEntity() {
    return CurrentUser(
      profile: profile.toEntity(),
      permissions: permissions.map((p) => p.toEntity()).toList(),
      accessToken: accessToken,
      lastLogin: lastLogin != null ? DateTime.parse(lastLogin!) : null,
    );
  }

  factory CurrentUserModel.fromEntity(CurrentUser entity) {
    return CurrentUserModel(
      profile: UserProfileModel.fromEntity(entity.profile),
      permissions: entity.permissions.map((p) => PermissionModel.fromEntity(p)).toList(),
      accessToken: entity.accessToken,
      lastLogin: entity.lastLogin?.toIso8601String(),
    );
  }
}
