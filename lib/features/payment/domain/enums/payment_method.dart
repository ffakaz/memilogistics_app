// lib/features/payment/domain/enums/payment_method.dart

import 'package:json_annotation/json_annotation.dart';

/// Payment method enum
@JsonEnum(valueField: 'value')
enum PaymentMethod {
  @JsonValue('CREDIT_CARD')
  creditCard('CREDIT_CARD'),

  @JsonValue('DEBIT_CARD')
  debitCard('DEBIT_CARD'),

  @JsonValue('BANK_TRANSFER')
  bankTransfer('BANK_TRANSFER'),

  @JsonValue('MOBILE_MONEY')
  mobileMoney('MOBILE_MONEY'),

  @JsonValue('CASH')
  cash('CASH'),

  @JsonValue('WALLET')
  wallet('WALLET');

  final String value;
  const PaymentMethod(this.value);

  /// Convert from string to enum
  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value.toUpperCase(),
      orElse: () => PaymentMethod.creditCard,
    );
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }

  /// Get icon name for UI
  String get iconName {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.debitCard:
        return 'credit_card';
      case PaymentMethod.bankTransfer:
        return 'account_balance';
      case PaymentMethod.mobileMoney:
        return 'phone_android';
      case PaymentMethod.cash:
        return 'money';
      case PaymentMethod.wallet:
        return 'account_balance_wallet';
    }
  }

  /// Check if method requires online processing
  bool get requiresOnlineProcessing {
    return this == PaymentMethod.creditCard ||
        this == PaymentMethod.debitCard ||
        this == PaymentMethod.mobileMoney ||
        this == PaymentMethod.wallet;
  }

  /// Check if method is instant
  bool get isInstant {
    return this == PaymentMethod.creditCard ||
        this == PaymentMethod.debitCard ||
        this == PaymentMethod.mobileMoney ||
        this == PaymentMethod.wallet;
  }
}
