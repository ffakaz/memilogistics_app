// lib/features/shipment_offer/presentation/providers/shipment_offer_provider.dart

import 'package:flutter/foundation.dart';
import 'package:memilogistics_app/features/auth/data/storage/token_storage.dart';
import '../../domain/entities/shipment_offer.dart';
import '../../data/services/shipment_offer_api_service.dart';
import '../../data/mappers/shipment_offer_mapper.dart';
import '../states/shipment_offer_state.dart';

/// Provider for managing shipment offers
/// Handles state management and API calls for the ShipmentOffer feature
class ShipmentOfferProvider extends ChangeNotifier {
  final ShipmentOfferApiService _apiService;
  final TokenStorage _tokenStorage;

  ShipmentOfferState _state = const ShipmentOfferState();
  final Set<int> _submittingShipmentIds = <int>{};
  final Set<int> _submittedShipmentIds = <int>{};

  ShipmentOfferProvider(this._apiService, this._tokenStorage);

  /// Current state
  ShipmentOfferState get state => _state;

  /// Convenience getters
  List<ShipmentOffer> get offers => _state.offers;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  String? get errorMessage => _state.error; // Alias for consistency
  bool isSubmittingForShipment(int shipmentId) => _submittingShipmentIds.contains(shipmentId);
  bool hasSubmittedOfferForShipment(int shipmentId) => _submittedShipmentIds.contains(shipmentId);

  /// Get carrier's offers from backend
  Future<void> getMyOffers() async {
    try {
      _state = _state.copyWith(isLoading: true, clearError: true);
      notifyListeners();

      final offerModels = await _apiService.getMyOffers();
      final offers = offerModels.map((model) => ShipmentOfferMapper.toEntity(model)).toList();
      _submittedShipmentIds
        ..clear()
        ..addAll(offers.map((offer) => offer.shipmentId));
      
      _state = _state.copyWith(
        offers: offers,
        isLoading: false,
      );
    } catch (e) {
      // The supplied OpenAPI contract does not expose /api/shipment-offers/my-offers.
      // Keep any offers submitted in this session visible instead of replacing
      // real state with mock data.
      _state = _state.copyWith(
        isLoading: false,
        error: _state.offers.isEmpty ? _getErrorMessage(e) : null,
      );
    }
    notifyListeners();
  }

  /// Alias for getMyOffers for consistency
  Future<void> loadMyOffers() => getMyOffers();

  /// Create new offer for a shipment
  /// Note: Backend uses "carrierCompanyId" not "carrierId"
  Future<void> createOffer(int shipmentId, int carrierCompanyId, double price) async {
    // Prevent users with SHIPPER role from submitting offers (client-side guard).
    try {
      final role = await _tokenStorage.getUserRole();
      if (role != null && role.toUpperCase() == 'SHIPPER') {
        _state = _state.copyWith(isLoading: false, error: 'You must be a carrier to submit offers.');
        notifyListeners();
        throw Exception('Only carriers can submit offers.');
      }
    } catch (e) {
      // If role cannot be determined, fail-safe: prevent offer submission.
      _state = _state.copyWith(isLoading: false, error: 'Unable to verify user role.');
      notifyListeners();
      rethrow;
    }
    if (_submittingShipmentIds.contains(shipmentId) || _submittedShipmentIds.contains(shipmentId)) {
      return;
    }

    _submittingShipmentIds.add(shipmentId);
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _apiService.createOffer(
        shipmentId: shipmentId,
        carrierCompanyId: carrierCompanyId,
        price: price,
      );

      _submittedShipmentIds.add(shipmentId);
      final submittedOffer = ShipmentOffer(
        id: -DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().toUtc(),
        price: price,
        shipmentId: shipmentId,
        shipmentTrackingNumber: '',
        carrierCompanyId: carrierCompanyId,
      );
      _state = _state.copyWith(
        isLoading: false,
        offers: [submittedOffer, ..._state.offers],
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      notifyListeners();
      rethrow; // Rethrow so UI can handle it
    } finally {
      _submittingShipmentIds.remove(shipmentId);
      notifyListeners();
    }
  }

  /// Cancel an existing offer
  Future<void> cancelOffer(int offerId) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _apiService.cancelOffer(offerId);
      final remainingOffers = _state.offers.where((offer) => offer.id != offerId).toList();
      _submittedShipmentIds
        ..clear()
        ..addAll(remainingOffers.map((offer) => offer.shipmentId));
      _state = _state.copyWith(
        offers: remainingOffers,
        isLoading: false,
      );
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
    // Assignment is a shipper-only action and must be performed via the
    // shipper review UI which routes through ShipmentProvider -> Repository.
    // This method is intentionally disabled to avoid accidental assignments
    // from carrier-side flows. Use the shipper offer review screen instead.
    throw Exception(
        'Assigning a carrier is a shipper-only action. Use the shipper offer review UI to accept offers.');
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
      
      // Check for specific HTTP status codes
      if (message.contains('401') || message.contains('Unauthorized')) {
        return 'Authentication failed. Please log in again.';
      } else if (message.contains('403') || message.contains('Forbidden')) {
        return 'You do not have permission to submit offers.';
      } else if (message.contains('404') || message.contains('Not Found')) {
        return 'Shipment not found or no longer available.';
      } else if (message.contains('400') || message.contains('Bad Request')) {
        return 'Invalid offer data. Please check your input.';
      } else if (message.contains('carrierId') || message.contains('carrier')) {
        return 'Carrier profile not found. Please create your profile first.';
      } else if (message.contains('Failed to get offers')) {
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
