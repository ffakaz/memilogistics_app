// lib/features/payment/domain/enums/payment_method.dart

import 'package:json_annotation/json_annotation.dart';

/// Payment method enum
@JsonEnum(valueField: 'value')
enum PaymentMethod {
  @JsonValue('CASH')
  cash('CASH'),

  @JsonValue('BANK_TRANSFER')
  bankTransfer('BANK_TRANSFER'),

  @JsonValue('CRYPTO_TRANSFER')
  cryptoTransfer('CRYPTO_TRANSFER'),

  @JsonValue('WALLET_TRANSFER')
  walletTransfer('WALLET_TRANSFER');

  final String value;
  const PaymentMethod(this.value);

  /// Convert from string to enum
  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value.toUpperCase(),
      orElse: () => PaymentMethod.bankTransfer,
    );
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cryptoTransfer:
        return 'Crypto Transfer';
      case PaymentMethod.walletTransfer:
        return 'Wallet Transfer';
    }
  }

  /// Get icon name for UI
  String get iconName {
    switch (this) {
      case PaymentMethod.cash:
        return 'money';
      case PaymentMethod.bankTransfer:
        return 'account_balance';
      case PaymentMethod.cryptoTransfer:
        return 'currency_bitcoin';
      case PaymentMethod.walletTransfer:
        return 'account_balance_wallet';
    }
  }

  /// Check if method requires online processing
  bool get requiresOnlineProcessing {
    return this == PaymentMethod.cryptoTransfer ||
        this == PaymentMethod.walletTransfer ||
        this == PaymentMethod.bankTransfer;
  }

  /// Check if method is instant
  bool get isInstant {
    return this == PaymentMethod.cash || this == PaymentMethod.walletTransfer;
  }
}
