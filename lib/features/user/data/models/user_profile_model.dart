// lib/features/user/data/models/user_profile_model.dart

import '../../domain/entities/user_profile.dart';
import '../../domain/enums/app_role.dart';
import '../../domain/enums/account_status.dart';

class UserProfileModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? company;
  final String? address;
  final String? avatarUrl;
  final String role;
  final String status;
  final String createdAt;
  final String? updatedAt;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.company,
    this.address,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      address: json['address'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'shipper',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'company': company,
      'address': address,
      'avatar_url': avatarUrl,
      'role': role,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      name: name,
      phone: phone,
      company: company,
      address: address,
      avatarUrl: avatarUrl,
      role: _parseRole(role),
      status: _parseStatus(status),
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      company: entity.company,
      address: entity.address,
      avatarUrl: entity.avatarUrl,
      role: entity.role.name,
      status: entity.status.name,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  static AppRole _parseRole(String role) {
    try {
      return AppRole.values.firstWhere((r) => r.name == role.toLowerCase());
    } catch (_) {
      return AppRole.shipper;
    }
  }

  static AccountStatus _parseStatus(String status) {
    try {
      return AccountStatus.values.firstWhere((s) => s.name == status.toLowerCase());
    } catch (_) {
      return AccountStatus.active;
    }
  }
}
