// lib/features/user/domain/entities/user_permission.dart

class UserPermission {
  final String id;
  final String name;
  final String description;
  final bool granted;

  const UserPermission({
    required this.id,
    required this.name,
    required this.description,
    required this.granted,
  });

  UserPermission copyWith({
    String? id,
    String? name,
    String? description,
    bool? granted,
  }) {
    return UserPermission(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      granted: granted ?? this.granted,
    );
  }
}
