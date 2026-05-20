// lib/features/payment/domain/entities/payment_record.dart

import 'package:equatable/equatable.dart';
import '../enums/payment_status.dart';
import '../enums/payment_method.dart';

/// Payment record entity
/// Represents a payment transaction for a shipment
class PaymentRecord extends Equatable {
  /// Unique payment record ID
  final int? id;

  /// Payment amount
  final double amount;

  /// Currency code (e.g., USD, EUR, ETB)
  final String currency;

  /// Current payment status
  final PaymentStatus paymentStatus;

  /// Payment method used
  final PaymentMethod paymentMethod;

  /// External payment gateway transaction ID
  final String? transactionId;

  /// Timestamp when payment was completed
  final DateTime? paidAt;

  /// Timestamp when payment record was created
  final DateTime? createdAt;

  /// Timestamp when payment record was last updated
  final DateTime? updatedAt;

  const PaymentRecord({
    this.id,
    required this.amount,
    required this.currency,
    required this.paymentStatus,
    required this.paymentMethod,
    this.transactionId,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if payment is completed
  bool get isCompleted => paymentStatus.isSuccessful;

  /// Check if payment is pending
  bool get isPending => paymentStatus.isPending;

  /// Check if payment has failed
  bool get hasFailed => paymentStatus.hasFailed;

  /// Check if payment was refunded
  bool get isRefunded => paymentStatus.isRefunded;

  /// Get formatted amount with currency
  String get formattedAmount => '$currency ${amount.toStringAsFixed(2)}';

  /// Copy with method for immutability
  PaymentRecord copyWith({
    int? id,
    double? amount,
    String? currency,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    String? transactionId,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        currency,
        paymentStatus,
        paymentMethod,
        transactionId,
        paidAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'PaymentRecord(id: $id, amount: $amount, currency: $currency, '
        'status: ${paymentStatus.value}, method: ${paymentMethod.value}, '
        'transactionId: $transactionId)';
  }
}
