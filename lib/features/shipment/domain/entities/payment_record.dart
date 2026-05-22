// lib/features/shipment/domain/entities/payment_record.dart

import 'currency.dart';

/// Payment method enum matching backend values
enum PaymentMethod {
  cash('CASH'),
  bankTransfer('BANK_TRANSFER'),
  cryptoTransfer('CRYPTO_TRANSFER'),
  walletTransfer('WALLET_TRANSFER');

  final String backendValue;
  const PaymentMethod(this.backendValue);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.backendValue == value.toUpperCase(),
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Payment record entity tracking payment information and confirmation
class PaymentRecord {
  final int id;
  final String shipment;
  final Currency currency;
  final double amount;
  final PaymentMethod paymentMethod;
  final bool shipperConfirmed;
  final bool carrierConfirmed;
  final DateTime? shipperConfirmedAt;
  final DateTime? carrierConfirmedAt;
  final String? note;

  const PaymentRecord({
    required this.id,
    required this.shipment,
    required this.currency,
    required this.amount,
    required this.paymentMethod,
    required this.shipperConfirmed,
    required this.carrierConfirmed,
    this.shipperConfirmedAt,
    this.carrierConfirmedAt,
    this.note,
  });

  bool get isFullyConfirmed => shipperConfirmed && carrierConfirmed;

  PaymentRecord copyWith({
    int? id,
    String? shipment,
    Currency? currency,
    double? amount,
    PaymentMethod? paymentMethod,
    bool? shipperConfirmed,
    bool? carrierConfirmed,
    DateTime? shipperConfirmedAt,
    DateTime? carrierConfirmedAt,
    String? note,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      shipment: shipment ?? this.shipment,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shipperConfirmed: shipperConfirmed ?? this.shipperConfirmed,
      carrierConfirmed: carrierConfirmed ?? this.carrierConfirmed,
      shipperConfirmedAt: shipperConfirmedAt ?? this.shipperConfirmedAt,
      carrierConfirmedAt: carrierConfirmedAt ?? this.carrierConfirmedAt,
      note: note ?? this.note,
    );
  }
}
