// lib/features/user/data/mappers/user_mapper.dart
//
// Extension methods for converting between entities and models
// Note: Most models already have toEntity() methods, these extensions
// provide a consistent interface and additional convenience methods

import '../../domain/entities/current_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_permission.dart';
import '../models/current_user_model.dart';
import '../models/user_profile_model.dart';
import '../models/permission_model.dart';

// Entity to Model conversions
extension CurrentUserMapper on CurrentUser {
  CurrentUserModel toModel() {
    return CurrentUserModel.fromEntity(this);
  }
}

extension UserProfileMapper on UserProfile {
  UserProfileModel toModel() {
    return UserProfileModel.fromEntity(this);
  }
}

extension UserPermissionMapper on UserPermission {
  PermissionModel toModel() {
    return PermissionModel.fromEntity(this);
  }
}

// Model to Entity conversions
// Note: These just delegate to the model's built-in toEntity() methods
// but provide a consistent extension-based API

extension CurrentUserModelMapper on CurrentUserModel {
  // Delegates to the model's toEntity() method
  CurrentUser toEntityExt() => toEntity();
}

extension UserProfileModelMapper on UserProfileModel {
  // Delegates to the model's toEntity() method
  UserProfile toEntityExt() => toEntity();
}

extension PermissionModelMapper on PermissionModel {
  // Delegates to the model's toEntity() method
  UserPermission toEntityExt() => toEntity();
}
