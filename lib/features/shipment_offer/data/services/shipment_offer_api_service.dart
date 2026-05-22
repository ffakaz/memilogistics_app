// lib/features/shipment_offer/data/services/shipment_offer_api_service.dart

import 'package:memilogistics_app/core/network/api_client.dart';
import 'package:memilogistics_app/core/utils/constants/api_constants.dart';
import '../models/shipment_offer_model.dart';

/// API service for shipment offer operations
/// Implements backend OpenAPI contract endpoints
class ShipmentOfferApiService {
  final ApiClient _apiClient;

  ShipmentOfferApiService(this._apiClient);

  /// Get carrier's offers
  /// GET /api/shipment-offers/my-offers
  Future<List<ShipmentOfferModel>> getMyOffers() async {
    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}${ShipmentOfferEndpoints.getMyOffers}',
    );
    return _parseOfferList(response);
  }

  /// Get offers submitted for a shipment.
  /// GET /api/shipments/{shipmentId}/offers
  Future<List<ShipmentOfferModel>> getShipmentOffers(int shipmentId) async {
    final endpoint = ShipmentOfferEndpoints.getShipmentOffers.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );
    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
    );
    return _parseOfferList(response);
  }

  /// Create a shipment offer
  /// POST /api/shipments/{shipmentId}/offer-shipment?price={price}
  Future<void> createOffer({
    required int shipmentId,
    required double price,
  }) async {
    final endpoint = ShipmentOfferEndpoints.createOffer.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );

    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'price': price},
    );
    _ensureSuccess(response, 'Failed to create offer');
  }

  /// Cancel a shipment offer
  /// POST /api/shipments/{shipmentOfferId}/cancel-shipment-offer
  Future<void> cancelOffer(int shipmentOfferId) async {
    final endpoint = ShipmentOfferEndpoints.cancelOffer.replaceAll(
      '{shipmentOfferId}',
      shipmentOfferId.toString(),
    );

    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
    );
    _ensureSuccess(response, 'Failed to cancel offer');
  }

  /// Assign carrier to shipment (accept offer)
  /// POST /api/shipments/{shipmentId}/assign-carrier?carrierId={carrierId}
  Future<void> assignCarrier({
    required int shipmentId,
    required int carrierId,
  }) async {
    final endpoint = ShipmentOfferEndpoints.assignCarrier.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );

    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'carrierId': carrierId},
    );
    _ensureSuccess(response, 'Failed to assign carrier');
  }

  List<ShipmentOfferModel> _parseOfferList(ApiResponse<dynamic> response) {
    _ensureSuccess(response, 'Failed to get offers');
    final data = response.data;
    final list = data is List
        ? data
        : data is Map
        ? data['data'] ?? data['result'] ?? data['content']
        : null;
    if (list is! List) {
      throw Exception('Backend returned an invalid offers response');
    }
    return list
        .map((json) => ShipmentOfferModel.fromJson(_asMap(json)))
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw Exception('Backend returned an invalid offer object');
  }

  void _ensureSuccess(ApiResponse<dynamic> response, String fallbackMessage) {
    if (!response.isSuccess) {
      throw Exception(response.message ?? fallbackMessage);
    }
  }
}
