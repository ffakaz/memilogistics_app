// lib/features/shipment/data/mappers/payment_record_mapper.dart

import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/payment_record.dart';
import 'currency_mapper.dart';

class PaymentRecordMapper {
  static PaymentRecord fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: JsonParsing.asInt(json['id']),
      shipment: JsonParsing.asString(json['shipment']),
      currency: CurrencyMapper.fromJson(json['currency']),
      amount: JsonParsing.asDouble(json['amount']),
      paymentMethod: PaymentMethod.fromString(
        JsonParsing.asString(json['paymentMethod'], fallback: 'BANK_TRANSFER'),
      ),
      shipperConfirmed: JsonParsing.asBool(json['shipperConfirmed']),
      carrierConfirmed: JsonParsing.asBool(json['carrierConfirmed']),
      shipperConfirmedAt: JsonParsing.asDateTime(json['shipperConfirmedAt']),
      carrierConfirmedAt: JsonParsing.asDateTime(json['carrierConfirmedAt']),
      note: json['note'] as String?,
    );
  }

  static Map<String, dynamic> toJson(PaymentRecord record) {
    return {
      'id': record.id,
      'shipment': record.shipment,
      'currency': CurrencyMapper.toJson(record.currency),
      'amount': record.amount,
      'paymentMethod': record.paymentMethod.backendValue,
      'shipperConfirmed': record.shipperConfirmed,
      'carrierConfirmed': record.carrierConfirmed,
      if (record.shipperConfirmedAt != null)
        'shipperConfirmedAt': record.shipperConfirmedAt!.toIso8601String(),
      if (record.carrierConfirmedAt != null)
        'carrierConfirmedAt': record.carrierConfirmedAt!.toIso8601String(),
      if (record.note != null) 'note': record.note,
    };
  }
}
