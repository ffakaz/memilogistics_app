// lib/features/user/presentation/widgets/profile_avatar.dart

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.initials,
    this.size = 80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitialsAvatar();
                  },
                ),
              )
            : _buildInitialsAvatar(),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
