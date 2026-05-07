// lib/features/user/domain/entities/user_profile.dart

import '../enums/app_role.dart';
import '../enums/account_status.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? company;
  final String? address;
  final String? avatarUrl;
  final AppRole role;
  final AccountStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
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

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? company,
    String? address,
    String? avatarUrl,
    AppRole? role,
    AccountStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get isActive => status == AccountStatus.active;
}
