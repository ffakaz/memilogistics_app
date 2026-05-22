// lib/features/shipment/data/mappers/currency_mapper.dart

import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/currency.dart';

class CurrencyMapper {
  static Currency fromJson(dynamic json) {
    if (json is String) {
      return _fromCode(json);
    }

    final map = JsonParsing.asMap(json) ?? const <String, dynamic>{};
    final code = JsonParsing.asString(
      map['currencyCode'] ?? map['code'],
      fallback: 'USD',
    ).toUpperCase();

    return Currency(
      currencyCode: code,
      displayName: JsonParsing.asString(
        map['displayName'],
        fallback: _displayNameFor(code),
      ),
      symbol: JsonParsing.asString(map['symbol'], fallback: _symbolFor(code)),
      defaultFractionDigits: JsonParsing.asInt(
        map['defaultFractionDigits'],
        fallback: 2,
      ),
      numericCode: JsonParsing.asInt(
        map['numericCode'],
        fallback: _numericCodeFor(code),
      ),
      numericCodeAsString: JsonParsing.asString(
        map['numericCodeAsString'],
        fallback: _numericCodeFor(code).toString(),
      ),
    );
  }

  static Map<String, dynamic> toJson(Currency currency) {
    return {
      'currencyCode': currency.currencyCode,
      'displayName': currency.displayName,
      'symbol': currency.symbol,
      'defaultFractionDigits': currency.defaultFractionDigits,
      'numericCode': currency.numericCode,
      'numericCodeAsString': currency.numericCodeAsString,
    };
  }

  static Currency _fromCode(String code) {
    final normalized = code.toUpperCase();
    return Currency(
      currencyCode: normalized,
      displayName: _displayNameFor(normalized),
      symbol: _symbolFor(normalized),
      defaultFractionDigits: 2,
      numericCode: _numericCodeFor(normalized),
      numericCodeAsString: _numericCodeFor(normalized).toString(),
    );
  }

  static String _displayNameFor(String code) {
    switch (code) {
      case 'ETB':
        return 'Ethiopian Birr';
      case 'USD':
        return 'US Dollar';
      default:
        return code;
    }
  }

  static String _symbolFor(String code) {
    switch (code) {
      case 'ETB':
        return 'Br';
      case 'USD':
        return r'$';
      default:
        return code;
    }
  }

  static int _numericCodeFor(String code) {
    switch (code) {
      case 'ETB':
        return 230;
      case 'USD':
        return 840;
      default:
        return 0;
    }
  }
}
