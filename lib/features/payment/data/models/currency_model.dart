// lib/features/payment/data/models/currency_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'currency_model.g.dart';

/// Currency model for payment request
/// Represents ISO 4217 currency information
@JsonSerializable()
class CurrencyModel {
  final String currencyCode;
  final int numericCode;
  final String numericCodeAsString;
  final String displayName;
  final String symbol;
  final int defaultFractionDigits;

  const CurrencyModel({
    required this.currencyCode,
    required this.numericCode,
    required this.numericCodeAsString,
    required this.displayName,
    required this.symbol,
    required this.defaultFractionDigits,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyModelToJson(this);

  /// Create default USD currency
  factory CurrencyModel.usd() {
    return const CurrencyModel(
      currencyCode: 'USD',
      numericCode: 840,
      numericCodeAsString: '840',
      displayName: 'US Dollar',
      symbol: '\$',
      defaultFractionDigits: 2,
    );
  }

  /// Create default ETB currency (Ethiopian Birr)
  factory CurrencyModel.etb() {
    return const CurrencyModel(
      currencyCode: 'ETB',
      numericCode: 230,
      numericCodeAsString: '230',
      displayName: 'Ethiopian Birr',
      symbol: 'Br',
      defaultFractionDigits: 2,
    );
  }

  /// Create currency from code
  factory CurrencyModel.fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return CurrencyModel.usd();
      case 'ETB':
        return CurrencyModel.etb();
      default:
        return CurrencyModel.usd(); // Default to USD
    }
  }

  @override
  String toString() {
    return 'CurrencyModel(code: $currencyCode, symbol: $symbol)';
  }
}
