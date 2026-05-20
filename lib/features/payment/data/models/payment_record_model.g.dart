// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRecordModel _$PaymentRecordModelFromJson(Map<String, dynamic> json) =>
    PaymentRecordModel(
      id: (json['id'] as num?)?.toInt(),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentStatus: json['paymentStatus'] as String,
      paymentMethod: json['paymentMethod'] as String,
      transactionId: json['transactionId'] as String?,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentRecordModelToJson(PaymentRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'currency': instance.currency,
      'paymentStatus': instance.paymentStatus,
      'paymentMethod': instance.paymentMethod,
      'transactionId': instance.transactionId,
      'paidAt': instance.paidAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
