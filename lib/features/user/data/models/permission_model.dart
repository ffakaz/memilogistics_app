// lib/features/user/data/models/permission_model.dart

import '../../domain/entities/user_permission.dart';

class PermissionModel {
  final String id;
  final String name;
  final String description;
  final bool granted;

  const PermissionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.granted,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      granted: json['granted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'granted': granted,
    };
  }

  UserPermission toEntity() {
    return UserPermission(
      id: id,
      name: name,
      description: description,
      granted: granted,
    );
  }

  factory PermissionModel.fromEntity(UserPermission entity) {
    return PermissionModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      granted: entity.granted,
    );
  }
}
