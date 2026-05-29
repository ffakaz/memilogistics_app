import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/payment_request.dart';
import '../../domain/enums/payment_method.dart';

part 'payment_request_model.g.dart';

/// Payment request model for JSON serialization
/// Matches the backend OpenAPI PaymentRequest contract:
/// { currencyCode, amount, paymentMethod, note }
@JsonSerializable(createFactory: false)
class PaymentRequestModel {
  final String currencyCode;
  final double amount;
  final String paymentMethod;
  final String? note;

  const PaymentRequestModel({
    required this.currencyCode,
    required this.amount,
    required this.paymentMethod,
    this.note,
  });

  /// Create model from the backend request shape.
  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) {
    return PaymentRequestModel(
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      note: json['note'] as String?,
    );
  }

  /// Convert model to backend OpenAPI shape:
  /// { currencyCode, amount, paymentMethod, note }
  Map<String, dynamic> toJson() {
    final json = _$PaymentRequestModelToJson(this);
    if (note == null || note!.trim().isEmpty) {
      json.remove('note');
    }
    return json;
  }

  /// Create model from entity
  factory PaymentRequestModel.fromEntity(PaymentRequest entity) {
    return PaymentRequestModel(
      currencyCode: entity.currency,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod.value,
      note: null, // Optional note
    );
  }

  /// Convert model to entity
  PaymentRequest toEntity() {
    return PaymentRequest(
      amount: amount,
      currency: currencyCode,
      paymentMethod: PaymentMethod.fromString(paymentMethod),
    );
  }

  @override
  String toString() {
    return 'PaymentRequestModel(amount: $amount, currency: $currencyCode, '
        'method: $paymentMethod, note: $note)';
  }
}
