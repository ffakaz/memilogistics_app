// lib/features/shipment/domain/entities/currency.dart

/// Currency entity representing monetary currency information
class Currency {
  final String currencyCode;
  final String displayName;
  final String symbol;
  final int defaultFractionDigits;
  final int numericCode;
  final String numericCodeAsString;

  const Currency({
    required this.currencyCode,
    required this.displayName,
    required this.symbol,
    required this.defaultFractionDigits,
    required this.numericCode,
    required this.numericCodeAsString,
  });

  Currency copyWith({
    String? currencyCode,
    String? displayName,
    String? symbol,
    int? defaultFractionDigits,
    int? numericCode,
    String? numericCodeAsString,
  }) {
    return Currency(
      currencyCode: currencyCode ?? this.currencyCode,
      displayName: displayName ?? this.displayName,
      symbol: symbol ?? this.symbol,
      defaultFractionDigits:
          defaultFractionDigits ?? this.defaultFractionDigits,
      numericCode: numericCode ?? this.numericCode,
      numericCodeAsString: numericCodeAsString ?? this.numericCodeAsString,
    );
  }
}
