// lib/features/payment/presentation/widgets/payment_status_badge.dart

import 'package:flutter/material.dart';
import '../../domain/enums/payment_status.dart';

/// Payment status badge widget
/// Displays payment status with appropriate color
class PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;
  final bool showIcon;

  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  Color _getStatusColor() {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.refunded:
        return Icons.replay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getStatusIcon(),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
