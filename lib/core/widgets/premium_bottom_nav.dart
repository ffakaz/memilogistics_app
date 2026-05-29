import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium Bottom Navigation Bar
/// Modern, animated navigation with smooth transitions
class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isShipper;

  const PremiumBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isShipper = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = isShipper ? _shipperItems : _carrierItems;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.charcoal.withAlpha((0.1 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing8,
            vertical: AppTheme.spacing8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _NavItem(
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static final List<_NavItemData> _shipperItems = [
    _NavItemData(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavItemData(
      icon: Icons.inventory_2_rounded,
      label: 'Shipments',
    ),
    _NavItemData(
      icon: Icons.add_circle_rounded,
      label: 'Create',
      isSpecial: true,
    ),
    _NavItemData(
      icon: Icons.local_offer_rounded,
      label: 'Offers',
    ),
    _NavItemData(
      icon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static final List<_NavItemData> _carrierItems = [
    _NavItemData(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavItemData(
      icon: Icons.view_list_rounded,
      label: 'Load Board',
    ),
    _NavItemData(
      icon: Icons.local_shipping_rounded,
      label: 'My Loads',
      isSpecial: true,
    ),
    _NavItemData(
      icon: Icons.attach_money_rounded,
      label: 'Earnings',
    ),
    _NavItemData(
      icon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];
}

class _NavItem extends StatelessWidget {
  final _NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item.isSpecial) {
      return _buildSpecialItem(context);
    }

    return _buildRegularItem(context);
  }

  Widget _buildSpecialItem(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.orangeGradient
              : LinearGradient(
                  colors: [
                    AppTheme.electricOrange.withAlpha((0.8 * 255).round()),
                    AppTheme.accentOrange.withAlpha((0.8 * 255).round()),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.electricOrange.withAlpha((0.3 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              item.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularItem(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? AppTheme.spacing16 : AppTheme.spacing12,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.electricOrange.withAlpha((0.1 * 255).round())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? AppTheme.electricOrange : AppTheme.darkGray,
              size: 24,
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? AppTheme.electricOrange : AppTheme.darkGray,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final bool isSpecial;

  _NavItemData({
    required this.icon,
    required this.label,
    this.isSpecial = false,
  });
}

/// Floating Action Button for special actions
class PremiumFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;

  const PremiumFAB({
    Key? key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: AppTheme.electricOrange,
        elevation: 8,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppTheme.electricOrange,
      elevation: 8,
      child: Icon(icon),
    );
  }
}

