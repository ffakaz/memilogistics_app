// lib/features/payment/presentation/widgets/payment_method_selector.dart

import 'package:flutter/material.dart';
import '../../domain/enums/payment_method.dart';

/// Payment method selector widget
/// Allows user to select a payment method
class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...PaymentMethod.values.map((method) {
          return _PaymentMethodTile(
            method: method,
            isSelected: selectedMethod == method,
            onTap: () => onMethodSelected(method),
          );
        }).toList(),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getMethodIcon() {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.mobileMoney:
        return Icons.phone_android;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMethodIcon(),
                  color: isSelected ? Colors.blue : Colors.grey.shade700,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Method Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.blue : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.isInstant ? 'Instant payment' : 'Processing time may vary',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection Indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
