import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../models/shipment_model.dart';
import '../models/shipment_request_model.dart';
import '../../../shipment_offer/data/models/shipment_offer_model.dart';

/// Shipment API Service - Matches backend OpenAPI specification
class ShipmentApiService {
  final ApiClient apiClient;

  ShipmentApiService({required this.apiClient});

  /// Create a new shipment
  /// POST /api/shipments/create
  Future<ShipmentModel> createShipment(ShipmentRequestModel request) async {
    final response = await apiClient.post(
      '${ApiConstants.apiPrefix}${ShipmentEndpoints.create}',
      data: request.toJson(),
    );
    return ShipmentModel.fromJson(response.data);
  }

  /// Get shipment by ID
  /// GET /api/shipments/{shipmentId}
  Future<ShipmentModel> getShipmentById(int shipmentId) async {
    final endpoint = ShipmentEndpoints.getById.replaceAll('{shipmentId}', shipmentId.toString());
    final response = await apiClient.get('${ApiConstants.apiPrefix}$endpoint');
    return ShipmentModel.fromJson(response.data);
  }

  /// List all shipments with pagination
  /// GET /api/shipments/list?page=0&size=20
  Future<List<ShipmentModel>> listShipments({int page = 0, int size = 20}) async {
    final response = await apiClient.get(
      '${ApiConstants.apiPrefix}${ShipmentEndpoints.list}',
      queryParameters: {'page': page, 'size': size},
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ShipmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Update shipment
  /// PATCH /api/shipments/update/{id}
  Future<ShipmentModel> updateShipment(int shipmentId, Map<String, dynamic> updates) async {
    final endpoint = ShipmentEndpoints.update.replaceAll('{id}', shipmentId.toString());
    final response = await apiClient.patch(
      '${ApiConstants.apiPrefix}$endpoint',
      data: updates,
    );
    return ShipmentModel.fromJson(response.data);
  }

  /// Delete shipment
  /// DELETE /api/shipments/{shipmentId}
  Future<void> deleteShipment(int shipmentId) async {
    final endpoint = ShipmentEndpoints.delete.replaceAll('{shipmentId}', shipmentId.toString());
    await apiClient.delete('${ApiConstants.apiPrefix}$endpoint');
  }

  /// Get shipment offers (separate endpoint!)
  /// GET /api/shipments/{shipmentId}/offers
  Future<List<ShipmentOfferModel>> getShipmentOffers(int shipmentId) async {
    final response = await apiClient.get(
      '${ApiConstants.apiPrefix}/shipments/$shipmentId/offers',
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ShipmentOfferModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Offer shipment (carrier makes offer)
  /// POST /api/shipments/{shipmentId}/offer-shipment?price=150.00
  Future<void> offerShipment(int shipmentId, double price) async {
    final endpoint = ShipmentEndpoints.offerShipment.replaceAll('{shipmentId}', shipmentId.toString());
    await apiClient.post(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'price': price},
    );
  }

  /// Assign carrier (shipper accepts offer)
  /// POST /api/shipments/{shipmentId}/assign-carrier?carrierId=123
  Future<void> assignCarrier(int shipmentId, int carrierId) async {
    final endpoint = ShipmentEndpoints.assignCarrier.replaceAll('{shipmentId}', shipmentId.toString());
    await apiClient.post(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'carrierId': carrierId},
    );
  }

  /// Cancel offer
  /// POST /api/shipments/{shipmentOfferId}/cancel-shipment-offer
  Future<void> cancelOffer(int shipmentOfferId) async {
    final endpoint = ShipmentEndpoints.cancelOffer.replaceAll('{shipmentOfferId}', shipmentOfferId.toString());
    await apiClient.post('${ApiConstants.apiPrefix}$endpoint');
  }

  /// Track by tracking number
  /// GET /api/shipments/tracking/{trackingNumber}
  Future<ShipmentModel> trackByTrackingNumber(String trackingNumber) async {
    final endpoint = ShipmentEndpoints.tracking.replaceAll('{trackingNumber}', trackingNumber);
    final response = await apiClient.get('${ApiConstants.apiPrefix}$endpoint');
    return ShipmentModel.fromJson(response.data);
  }

  /// Get dashboard info
  /// GET /api/shipments/dashboard
  Future<Map<String, dynamic>> getDashboardInfo() async {
    final response = await apiClient.get('${ApiConstants.apiPrefix}${ShipmentEndpoints.dashboard}');
    return response.data as Map<String, dynamic>;
  }

  /// List shipments by origin
  /// GET /api/shipments/list-by-origin/{origin}?page=0&size=20
  Future<List<ShipmentModel>> listByOrigin(String origin, {int page = 0, int size = 20}) async {
    final endpoint = ShipmentEndpoints.listByOrigin.replaceAll('{origin}', origin);
    final response = await apiClient.get(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'page': page, 'size': size},
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ShipmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// List shipments by destination
  /// GET /api/shipments/list-by-destination/{destination}?page=0&size=20
  Future<List<ShipmentModel>> listByDestination(String destination, {int page = 0, int size = 20}) async {
    final endpoint = ShipmentEndpoints.listByDestination.replaceAll('{destination}', destination);
    final response = await apiClient.get(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'page': page, 'size': size},
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ShipmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// List fragile/non-fragile shipments
  /// GET /api/shipments/list/fragile?fragile=true&page=0&size=20
  Future<List<ShipmentModel>> listByFragile(bool fragile, {int page = 0, int size = 20}) async {
    final response = await apiClient.get(
      '${ApiConstants.apiPrefix}${ShipmentEndpoints.listByFragile}',
      queryParameters: {'fragile': fragile, 'page': page, 'size': size},
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ShipmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Update shipment status
  /// PATCH /api/shipments/{shipmentId}/update-status
  Future<Map<String, dynamic>> updateShipmentStatus(
    int shipmentId, {
    String? location,
    String? status,
  }) async {
    final endpoint = ShipmentEndpoints.updateStatus.replaceAll('{shipmentId}', shipmentId.toString());
    final response = await apiClient.patch(
      '${ApiConstants.apiPrefix}$endpoint',
      data: {
        if (location != null) 'location': location,
        if (status != null) 'status': status,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get shipment events
  /// GET /api/shipments/{shipmentId}/events
  Future<List<Map<String, dynamic>>> getShipmentEvents(int shipmentId) async {
    final endpoint = ShipmentEndpoints.getEvents.replaceAll('{shipmentId}', shipmentId.toString());
    final response = await apiClient.get('${ApiConstants.apiPrefix}$endpoint');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => json as Map<String, dynamic>).toList();
  }
}