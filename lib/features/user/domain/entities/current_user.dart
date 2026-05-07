// lib/features/user/domain/entities/current_user.dart

import 'user_profile.dart';
import 'user_permission.dart';

class CurrentUser {
  final UserProfile profile;
  final List<UserPermission> permissions;
  final String? accessToken;
  final DateTime? lastLogin;

  const CurrentUser({
    required this.profile,
    required this.permissions,
    this.accessToken,
    this.lastLogin,
  });

  CurrentUser copyWith({
    UserProfile? profile,
    List<UserPermission>? permissions,
    String? accessToken,
    DateTime? lastLogin,
  }) {
    return CurrentUser(
      profile: profile ?? this.profile,
      permissions: permissions ?? this.permissions,
      accessToken: accessToken ?? this.accessToken,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  bool hasPermission(String permissionId) {
    return permissions.any((p) => p.id == permissionId && p.granted);
  }

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;
}
