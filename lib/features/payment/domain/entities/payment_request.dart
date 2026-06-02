// lib/features/payment/domain/entities/payment_request.dart

import 'package:equatable/equatable.dart';
import '../enums/payment_method.dart';

/// Payment request entity
/// Used to initiate a payment for a shipment
class PaymentRequest extends Equatable {
  /// Payment amount
  final double amount;

  /// Currency code (e.g., USD, EUR, ETB)
  final String currency;

  /// Payment method to use
  final PaymentMethod paymentMethod;

  /// Optional payment note sent to the backend
  final String? note;

  const PaymentRequest({
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.note,
  });

  /// Get formatted amount with currency
  String get formattedAmount => '$currency ${amount.toStringAsFixed(2)}';

  /// Validate payment request
  bool get isValid {
    return amount > 0 && currency.isNotEmpty;
  }

  /// Copy with method for immutability
  PaymentRequest copyWith({
    double? amount,
    String? currency,
    PaymentMethod? paymentMethod,
    String? note,
  }) {
    return PaymentRequest(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [amount, currency, paymentMethod, note];

  @override
  String toString() {
    return 'PaymentRequest(amount: $amount, currency: $currency, '
        'method: ${paymentMethod.value})';
  }
}
