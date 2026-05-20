// lib/features/shipment_offer/presentation/states/shipment_offer_state.dart

import '../../domain/entities/shipment_offer.dart';

/// State class for ShipmentOffer feature
/// Manages the state of offers, loading status, and errors
class ShipmentOfferState {
  final List<ShipmentOffer> offers;
  final bool isLoading;
  final String? error;
  final ShipmentOffer? selectedOffer;

  const ShipmentOfferState({
    this.offers = const [],
    this.isLoading = false,
    this.error,
    this.selectedOffer,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  ShipmentOfferState copyWith({
    List<ShipmentOffer>? offers,
    bool? isLoading,
    String? error,
    ShipmentOffer? selectedOffer,
    bool clearError = false,
    bool clearSelectedOffer = false,
  }) {
    return ShipmentOfferState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedOffer: clearSelectedOffer ? null : (selectedOffer ?? this.selectedOffer),
    );
  }

  /// Returns true if there are offers available
  bool get hasOffers => offers.isNotEmpty;

  /// Returns true if there's an error
  bool get hasError => error != null;

  @override
  String toString() {
    return 'ShipmentOfferState(offers: ${offers.length}, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShipmentOfferState &&
        other.offers == offers &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.selectedOffer == selectedOffer;
  }

  @override
  int get hashCode {
    return offers.hashCode ^
        isLoading.hashCode ^
        error.hashCode ^
        selectedOffer.hashCode;
  }
}
