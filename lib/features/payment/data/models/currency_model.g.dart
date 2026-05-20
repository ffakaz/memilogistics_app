// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyModel _$CurrencyModelFromJson(Map<String, dynamic> json) =>
    CurrencyModel(
      currencyCode: json['currencyCode'] as String,
      numericCode: (json['numericCode'] as num).toInt(),
      numericCodeAsString: json['numericCodeAsString'] as String,
      displayName: json['displayName'] as String,
      symbol: json['symbol'] as String,
      defaultFractionDigits: (json['defaultFractionDigits'] as num).toInt(),
    );

Map<String, dynamic> _$CurrencyModelToJson(CurrencyModel instance) =>
    <String, dynamic>{
      'currencyCode': instance.currencyCode,
      'numericCode': instance.numericCode,
      'numericCodeAsString': instance.numericCodeAsString,
      'displayName': instance.displayName,
      'symbol': instance.symbol,
      'defaultFractionDigits': instance.defaultFractionDigits,
    };
