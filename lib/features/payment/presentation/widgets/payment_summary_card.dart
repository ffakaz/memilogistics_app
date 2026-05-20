// lib/features/payment/presentation/widgets/payment_summary_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/payment_record.dart';
import 'payment_status_badge.dart';

/// Payment summary card widget
/// Displays payment details in a card format
class PaymentSummaryCard extends StatelessWidget {
  final PaymentRecord paymentRecord;
  final VoidCallback? onTap;

  const PaymentSummaryCard({
    super.key,
    required this.paymentRecord,
    this.onTap,
  });

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Amount and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    paymentRecord.formattedAmount,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  PaymentStatusBadge(status: paymentRecord.paymentStatus),
                ],
              ),

              const SizedBox(height: 16),

              // Payment Method
              _buildInfoRow(
                icon: Icons.payment,
                label: 'Payment Method',
                value: paymentRecord.paymentMethod.displayName,
              ),

              const SizedBox(height: 12),

              // Transaction ID (if available)
              if (paymentRecord.transactionId != null) ...[
                _buildInfoRow(
                  icon: Icons.receipt_long,
                  label: 'Transaction ID',
                  value: paymentRecord.transactionId!,
                ),
                const SizedBox(height: 12),
              ],

              // Payment Date
              if (paymentRecord.paidAt != null) ...[
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Paid At',
                  value: _formatDateTime(paymentRecord.paidAt!),
                ),
              ] else if (paymentRecord.createdAt != null) ...[
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Created At',
                  value: _formatDateTime(paymentRecord.createdAt!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
