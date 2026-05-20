// lib/features/shipment_offer/presentation/providers/shipment_offer_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/services/shipment_offer_api_service.dart';
import '../../data/mappers/shipment_offer_mapper.dart';
import '../states/shipment_offer_state.dart';

/// Provider for managing shipment offers
/// Handles state management and API calls for the ShipmentOffer feature
class ShipmentOfferProvider extends ChangeNotifier {
  final ShipmentOfferApiService _apiService;

  ShipmentOfferState _state = const ShipmentOfferState();

  ShipmentOfferProvider(this._apiService);

  /// Current state
  ShipmentOfferState get state => _state;

  /// Convenience getters
  List<dynamic> get offers => _state.offers;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  String? get errorMessage => _state.error; // Alias for consistency

  /// Get carrier's offers from backend
  Future<void> getMyOffers() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final offerModels = await _apiService.getMyOffers();
      final offers = offerModels.map((model) => ShipmentOfferMapper.toEntity(model)).toList();
      
      _state = _state.copyWith(
        offers: offers,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
    notifyListeners();
  }

  /// Alias for getMyOffers for consistency
  Future<void> loadMyOffers() => getMyOffers();

  /// Create new offer for a shipment
  Future<void> createOffer(int shipmentId, double price) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _apiService.createOffer(
        shipmentId: shipmentId,
        price: price,
      );
      // Refresh the offers list after creating
      await getMyOffers();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      notifyListeners();
      rethrow; // Rethrow so UI can handle it
    }
  }

  /// Cancel an existing offer
  Future<void> cancelOffer(int offerId) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _apiService.cancelOffer(offerId);
      // Refresh the offers list after cancelling
      await getMyOffers();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      notifyListeners();
      rethrow; // Rethrow so UI can handle it
    }
  }

  /// Assign carrier to shipment (accept offer)
  Future<void> assignCarrier(int shipmentId, int carrierId) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _apiService.assignCarrier(
        shipmentId: shipmentId,
        carrierId: carrierId,
      );
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      notifyListeners();
      rethrow; // Rethrow so UI can handle it
    }
  }

  /// Clear error message
  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  /// Reset state to initial
  void reset() {
    _state = const ShipmentOfferState();
    notifyListeners();
  }

  /// Extract user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('Failed to get offers')) {
        return 'Unable to load offers. Please try again.';
      } else if (message.contains('Failed to create offer')) {
        return 'Unable to submit offer. Please try again.';
      } else if (message.contains('Failed to cancel offer')) {
        return 'Unable to cancel offer. Please try again.';
      } else if (message.contains('Failed to assign carrier')) {
        return 'Unable to accept offer. Please try again.';
      }
      return message.replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
