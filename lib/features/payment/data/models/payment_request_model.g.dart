// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequestModel _$PaymentRequestModelFromJson(Map<String, dynamic> json) =>
    PaymentRequestModel(
      currency: CurrencyModel.fromJson(
        json['currency'] as Map<String, dynamic>,
      ),
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$PaymentRequestModelToJson(
  PaymentRequestModel instance,
) => <String, dynamic>{
  'currency': instance.currency,
  'amount': instance.amount,
  'paymentMethod': instance.paymentMethod,
  'note': instance.note,
};
