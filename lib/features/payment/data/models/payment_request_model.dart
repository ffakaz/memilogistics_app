// lib/features/payment/data/models/payment_request_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/enums/payment_method.dart';
import 'currency_model.dart';

part 'payment_request_model.g.dart';

/// Payment request model for JSON serialization
@JsonSerializable()
class PaymentRequestModel {
  final CurrencyModel currency;
  final double amount;
  final String paymentMethod;
  final String? note;

  const PaymentRequestModel({
    required this.currency,
    required this.amount,
    required this.paymentMethod,
    this.note,
  });

  /// Create model from JSON
  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$PaymentRequestModelToJson(this);

  /// Create model from entity
  factory PaymentRequestModel.fromEntity(PaymentRequest entity) {
    return PaymentRequestModel(
      currency: CurrencyModel.fromCode(entity.currency),
      amount: entity.amount,
      paymentMethod: entity.paymentMethod.value,
      note: null, // Optional note
    );
  }

  /// Convert model to entity
  PaymentRequest toEntity() {
    return PaymentRequest(
      amount: amount,
      currency: currency.currencyCode,
      paymentMethod: PaymentMethod.fromString(paymentMethod),
    );
  }

  @override
  String toString() {
    return 'PaymentRequestModel(amount: $amount, currency: ${currency.currencyCode}, '
        'method: $paymentMethod, note: $note)';
  }
}
