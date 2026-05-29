import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/shipment/domain/enums/shipment_status.dart';

/// Premium Status Chip Widget
/// Beautiful, animated status indicators for shipments
class StatusChip extends StatelessWidget {
  final ShipmentStatus status;
  final bool showIcon;
  final double? fontSize;

  const StatusChip({
    Key? key,
    required this.status,
    this.showIcon = true,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.color,
            config.color.withAlpha((0.8 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: config.color.withAlpha((0.3 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: fontSize ?? 14,
              color: Colors.white,
            ),
            const SizedBox(width: AppTheme.spacing8),
          ],
          Text(
            config.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return _StatusConfig(
          label: 'Pending',
          color: AppTheme.statusPending,
          icon: Icons.schedule_rounded,
        );
      case ShipmentStatus.accepted:
        return _StatusConfig(
          label: 'Accepted',
          color: AppTheme.statusAssigned,
          icon: Icons.check_circle_outline_rounded,
        );
      case ShipmentStatus.assigned:
        return _StatusConfig(
          label: 'Assigned',
          color: AppTheme.statusAssigned,
          icon: Icons.assignment_turned_in_rounded,
        );
      case ShipmentStatus.pickedUp:
        return _StatusConfig(
          label: 'Picked Up',
          color: AppTheme.statusInTransit,
          icon: Icons.local_shipping_outlined,
        );
      case ShipmentStatus.inTransit:
        return _StatusConfig(
          label: 'In Transit',
          color: AppTheme.statusInTransit,
          icon: Icons.local_shipping_rounded,
        );
      case ShipmentStatus.arrivedAtDestination:
        return _StatusConfig(
          label: 'Arrived',
          color: AppTheme.statusDelivered,
          icon: Icons.location_on_rounded,
        );
      case ShipmentStatus.delivered:
        return _StatusConfig(
          label: 'Delivered',
          color: AppTheme.statusDelivered,
          icon: Icons.check_circle_rounded,
        );
      case ShipmentStatus.completed:
        return _StatusConfig(
          label: 'Completed',
          color: AppTheme.statusDelivered,
          icon: Icons.done_all_rounded,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// Animated Status Chip with pulse effect
class AnimatedStatusChip extends StatefulWidget {
  final ShipmentStatus status;
  final bool showIcon;

  const AnimatedStatusChip({
    Key? key,
    required this.status,
    this.showIcon = true,
  }) : super(key: key);

  @override
  State<AnimatedStatusChip> createState() => _AnimatedStatusChipState();
}

class _AnimatedStatusChipState extends State<AnimatedStatusChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only animate for in-transit status
    if (widget.status == ShipmentStatus.inTransit) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: StatusChip(
          status: widget.status,
          showIcon: widget.showIcon,
        ),
      );
    }

    return StatusChip(
      status: widget.status,
      showIcon: widget.showIcon,
    );
  }
}
