import 'package:flutter/material.dart';

import '../../domain/entities/shipper_company.dart';

class ShipperProfileAvatar extends StatelessWidget {
  final ShipperCompany? profile;
  final double size;
  final VoidCallback? onTap;

  const ShipperProfileAvatar({
    super.key,
    required this.profile,
    this.size = 44,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final letter = _initial(profile);

    final avatar = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: theme.colorScheme.primary,
        child: Text(
          letter,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    if (onTap == null) return avatar;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(2), child: avatar),
      ),
    );
  }

  String _initial(ShipperCompany? company) {
    final name = company?.firstName.trim();
    if (name != null && name.isNotEmpty) return name[0].toUpperCase();
    final companyName = company?.companyName.trim();
    if (companyName != null && companyName.isNotEmpty) {
      return companyName[0].toUpperCase();
    }
    return '?';
  }
}
