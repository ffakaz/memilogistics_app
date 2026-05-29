// lib/features/shipment_offer/data/services/shipment_offer_api_service.dart

import 'package:memilogistics_app/core/network/api_client.dart';
import 'package:memilogistics_app/core/network/request_builder.dart';
import 'package:memilogistics_app/core/network/api_routes.dart';
import 'package:memilogistics_app/core/error/http_error_mapper.dart';
import '../models/shipment_offer_model.dart';

/// API service for shipment offer operations
/// Implements backend OpenAPI contract endpoints
class ShipmentOfferApiService {
  final ApiClient _apiClient;

  ShipmentOfferApiService(this._apiClient);

  /// Get carrier's offers
  /// GET /api/shipment-offers/my-offers
  Future<List<ShipmentOfferModel>> getMyOffers() async {
    final url = RequestBuilder.buildFullUrl(ApiRoutes.getMyOffers, {});
    final response = await _apiClient.get<dynamic>(url);
    return _parseOfferList(response);
  }

  /// Get offers submitted for a shipment.
  /// GET /api/shipment/{shipmentId}/offers
  Future<List<ShipmentOfferModel>> getShipmentOffers(int shipmentId) async {
    final url = RequestBuilder.buildFullUrl(ApiRoutes.getShipmentOffers, {'shipmentId': shipmentId});
    final response = await _apiClient.get<dynamic>(url);
    return _parseOfferList(response);
  }

  /// Create a shipment offer
  /// POST /api/shipments/{shipmentId}/offer-shipment (with price as query parameter)
  /// Note: Backend automatically extracts carrierCompanyId from JWT token
  Future<void> createOffer({
    required int shipmentId,
    required int carrierCompanyId, // Keep for compatibility but not sent to backend
    required double price,
  }) async {
    print('🔵 Creating Shipment Offer:');
    print('  Shipment ID: $shipmentId');
    print('  Carrier Company ID: $carrierCompanyId (from JWT token)');
    print('  Price: \$${price.toStringAsFixed(2)}');
    
    // Build the endpoint with shipmentId
    final url = RequestBuilder.buildFullUrl(
      ApiRoutes.createOffer,
      {'shipmentId': shipmentId},
      queryParameters: {'price': price},
      requiredQueryKeys: ['price'],
    );

    print('  Trying endpoint: POST $url');

    try {
      final response = await _apiClient.post<dynamic>(
        url,
      );
      
      print('✅ Offer Created Successfully');
      print('  Response Status: ${response.statusCode}');
      print('  Response Data: ${response.data}');
      
      _ensureSuccess(response, 'Failed to create offer');
    } catch (e) {
      print('❌ Offer Creation Failed');
      print('  Error: $e');
      print('  Error Type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Cancel a shipment offer
  /// POST /api/shipments/{shipmentOfferId}/cancel-shipment-offer
  Future<void> cancelOffer(int shipmentOfferId) async {
    final url = RequestBuilder.buildFullUrl(
      ApiRoutes.cancelOffer,
      {'shipmentOfferId': shipmentOfferId},
    );

    final response = await _apiClient.post<dynamic>(url);
    _ensureSuccess(response, 'Failed to cancel offer');
  }

  /// Assign carrier to shipment (accept offer)
  /// POST /api/shipments/{shipmentId}/assign-carrier?carrierId={carrierId}
  Future<void> assignCarrier({
    required int shipmentId,
    required int carrierId,
  }) async {
    final url = RequestBuilder.buildFullUrl(
      ApiRoutes.assignCarrier,
      {'shipmentId': shipmentId},
      queryParameters: {'carrierId': carrierId},
      requiredQueryKeys: ['carrierId'],
    );

    final response = await _apiClient.post<dynamic>(url);
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
      throw HttpErrorMapper.map(response.statusCode, response.message ?? fallbackMessage);
    }
  }
}
