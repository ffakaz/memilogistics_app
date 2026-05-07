// lib/features/user/presentation/widgets/role_badge.dart

import 'package:flutter/material.dart';
import '../../domain/enums/app_role.dart';

class RoleBadge extends StatelessWidget {
  final AppRole role;
  final bool showDescription;

  const RoleBadge({
    super.key,
    required this.role,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(role),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                role.displayName,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showDescription)
                Text(
                  role.description,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return Colors.red;
      case AppRole.shipper:
        return Colors.blue;
      case AppRole.carrier:
        return Colors.orange;
    }
  }

  IconData _getRoleIcon(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return Icons.admin_panel_settings;
      case AppRole.shipper:
        return Icons.local_shipping;
      case AppRole.carrier:
        return Icons.support_agent;
    }
  }
}
