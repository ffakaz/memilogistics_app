// lib/features/payment/data/models/payment_record_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/enums/payment_status.dart';
import '../../domain/enums/payment_method.dart';

part 'payment_record_model.g.dart';

/// Payment record model for JSON serialization
@JsonSerializable(createFactory: false)
class PaymentRecordModel {
  final int? id;
  final double amount;
  final String currency;

  @JsonKey(name: 'paymentStatus')
  final String paymentStatus;

  @JsonKey(name: 'paymentMethod')
  final String paymentMethod;

  final String? transactionId;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentRecordModel({
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

  /// Create model from JSON
  factory PaymentRecordModel.fromJson(Map<String, dynamic> json) {
    return PaymentRecordModel(
      id: json['id'] == null ? null : JsonParsing.asInt(json['id']),
      amount: JsonParsing.asDouble(json['amount']),
      currency: _parseCurrency(json['currency']),
      paymentStatus: JsonParsing.asString(
        json['paymentStatus'],
        fallback: 'PENDING',
      ),
      paymentMethod: JsonParsing.asString(
        json['paymentMethod'],
        fallback: 'BANK_TRANSFER',
      ),
      transactionId: json['transactionId'] as String?,
      paidAt: JsonParsing.asDateTime(json['paidAt']),
      createdAt: JsonParsing.asDateTime(json['createdAt']),
      updatedAt: JsonParsing.asDateTime(json['updatedAt']),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$PaymentRecordModelToJson(this);

  /// Create model from entity
  factory PaymentRecordModel.fromEntity(PaymentRecord entity) {
    return PaymentRecordModel(
      id: entity.id,
      amount: entity.amount,
      currency: entity.currency,
      paymentStatus: entity.paymentStatus.value,
      paymentMethod: entity.paymentMethod.value,
      transactionId: entity.transactionId,
      paidAt: entity.paidAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to entity
  PaymentRecord toEntity() {
    return PaymentRecord(
      id: id,
      amount: amount,
      currency: currency,
      paymentStatus: PaymentStatus.fromString(paymentStatus),
      paymentMethod: PaymentMethod.fromString(paymentMethod),
      transactionId: transactionId,
      paidAt: paidAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentRecordModel(id: $id, amount: $amount, currency: $currency, '
        'status: $paymentStatus, method: $paymentMethod)';
  }

  static String _parseCurrency(dynamic value) {
    if (value is Map) {
      return JsonParsing.asString(value['currencyCode'], fallback: 'ETB');
    }
    return JsonParsing.asString(value, fallback: 'ETB');
  }
}
