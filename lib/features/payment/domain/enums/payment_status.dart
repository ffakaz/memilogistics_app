// lib/features/payment/domain/enums/payment_status.dart

import 'package:json_annotation/json_annotation.dart';

/// Payment status enum matching backend API
@JsonEnum(valueField: 'value')
enum PaymentStatus {
  @JsonValue('PENDING')
  pending('PENDING'),

  @JsonValue('COMPLETED')
  completed('COMPLETED'),

  @JsonValue('FAILED')
  failed('FAILED'),

  @JsonValue('REFUNDED')
  refunded('REFUNDED');

  final String value;
  const PaymentStatus(this.value);

  /// Convert from string to enum
  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value.toUpperCase(),
      orElse: () => PaymentStatus.pending,
    );
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  /// Get color for status badge
  String get colorHex {
    switch (this) {
      case PaymentStatus.pending:
        return '#FFA500'; // Orange
      case PaymentStatus.completed:
        return '#4CAF50'; // Green
      case PaymentStatus.failed:
        return '#F44336'; // Red
      case PaymentStatus.refunded:
        return '#2196F3'; // Blue
    }
  }

  /// Check if payment is successful
  bool get isSuccessful => this == PaymentStatus.completed;

  /// Check if payment is pending
  bool get isPending => this == PaymentStatus.pending;

  /// Check if payment has failed
  bool get hasFailed => this == PaymentStatus.failed;

  /// Check if payment was refunded
  bool get isRefunded => this == PaymentStatus.refunded;
}
