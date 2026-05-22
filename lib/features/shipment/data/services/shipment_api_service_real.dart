// lib/features/shipment/data/services/shipment_api_service_real.dart

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../shipment_offer/data/models/shipment_offer_model.dart';
import '../models/create_shipment_request.dart';
import '../models/shipment_response_model.dart';

class ShipmentApiServiceReal {
  final ApiClient _apiClient;

  ShipmentApiServiceReal(this._apiClient);

  /// Create a new shipment
  /// POST /api/shipments/create
  Future<ShipmentResponseModel> createShipment(
    CreateShipmentRequest request,
  ) async {
    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.apiPrefix}${ShipmentEndpoints.create}',
      data: request.toJson(),
    );
    return ShipmentResponseModel.fromJson(_requireMap(response));
  }

  /// Get list of shipments with pagination
  /// GET /api/shipments/list?page=0&size=20
  Future<List<ShipmentResponseModel>> listShipments({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}${ShipmentEndpoints.list}',
      queryParameters: {'page': page, 'size': size},
    );
    return _parseShipmentList(response);
  }

  /// Get shipment by ID
  /// GET /api/shipments/{shipmentId}
  Future<ShipmentResponseModel> getShipment(int shipmentId) async {
    final endpoint = ShipmentEndpoints.getById.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );

    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
    );
    return ShipmentResponseModel.fromJson(_requireMap(response));
  }

  /// Get shipment by tracking number
  /// GET /api/shipments/tracking/{trackingNumber}
  Future<ShipmentResponseModel> getShipmentByTracking(
    String trackingNumber,
  ) async {
    final endpoint = ShipmentEndpoints.tracking.replaceAll(
      '{trackingNumber}',
      trackingNumber,
    );

    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
    );
    return ShipmentResponseModel.fromJson(_requireMap(response));
  }

  /// Delete shipment
  /// DELETE /api/shipments/{shipmentId}
  Future<void> deleteShipment(int shipmentId) async {
    final endpoint = ShipmentEndpoints.delete.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );

    final response = await _apiClient.delete<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
    );
    _ensureSuccess(response);
  }

  /// Get dashboard statistics
  /// GET /api/shipments/dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.apiPrefix}${ShipmentEndpoints.dashboard}',
    );
    return _requireData(response);
  }

  /// List shipments by origin
  /// GET /api/shipments/list-by-origin/{origin}
  Future<List<ShipmentResponseModel>> listByOrigin(
    String origin, {
    int page = 0,
    int size = 20,
  }) async {
    final endpoint = ShipmentEndpoints.listByOrigin.replaceAll(
      '{origin}',
      Uri.encodeComponent(origin),
    );

    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'page': page, 'size': size},
    );
    return _parseShipmentList(response);
  }

  /// List shipments by destination
  /// GET /api/shipments/list-by-destination/{destination}
  Future<List<ShipmentResponseModel>> listByDestination(
    String destination, {
    int page = 0,
    int size = 20,
  }) async {
    final endpoint = ShipmentEndpoints.listByDestination.replaceAll(
      '{destination}',
      Uri.encodeComponent(destination),
    );

    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'page': page, 'size': size},
    );
    return _parseShipmentList(response);
  }

  /// List shipments by fragile status
  /// GET /api/shipments/list/fragile?fragile=true
  Future<List<ShipmentResponseModel>> listByFragile(
    bool fragile, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}${ShipmentEndpoints.listByFragile}',
      queryParameters: {'fragile': fragile, 'page': page, 'size': size},
    );
    return _parseShipmentList(response);
  }

  Future<void> offerShipment({
    required int shipmentId,
    required double price,
  }) async {
    final endpoint = ShipmentEndpoints.offerShipment.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );
    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'price': price},
    );
    _ensureSuccess(response);
  }

  Future<void> cancelShipmentOffer(int shipmentOfferId) async {
    final endpoint = ShipmentEndpoints.cancelOffer.replaceAll(
      '{shipmentOfferId}',
      shipmentOfferId.toString(),
    );
    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
    );
    _ensureSuccess(response);
  }

  Future<void> assignCarrier({
    required int shipmentId,
    required int carrierId,
  }) async {
    final endpoint = ShipmentEndpoints.assignCarrier.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );
    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
      queryParameters: {'carrierId': carrierId},
    );
    _ensureSuccess(response);
  }

  Future<ShipmentResponseModel> updateStatus({
    required int shipmentId,
    required String location,
    required String status,
  }) async {
    final endpoint = ShipmentEndpoints.updateStatus.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );
    final response = await _apiClient.patch<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
      data: {'location': location, 'status': status},
    );
    return ShipmentResponseModel.fromJson(_requireMap(response));
  }

  Future<List<ShipmentOfferModel>> getShipmentOffers(int shipmentId) async {
    final endpoint = ShipmentEndpoints.getOffers.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );
    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
    );
    return _requireList(
      response,
    ).map((json) => ShipmentOfferModel.fromJson(_asMap(json))).toList();
  }

  Future<List<Map<String, dynamic>>> getShipmentEvents(int shipmentId) async {
    final endpoint = ShipmentEndpoints.getEvents.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );
    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}$endpoint',
    );
    return _requireList(response).map(_asMap).toList();
  }

  List<ShipmentResponseModel> _parseShipmentList(
    ApiResponse<dynamic> response,
  ) {
    return _requireList(
      response,
    ).map((json) => ShipmentResponseModel.fromJson(_asMap(json))).toList();
  }

  Map<String, dynamic> _requireMap(ApiResponse<dynamic> response) {
    final data = _requireData(response);
    return _asMap(data);
  }

  List<dynamic> _requireList(ApiResponse<dynamic> response) {
    final data = _requireData(response);
    if (data is List) return data;
    if (data is Map) {
      final nested = data['data'] ?? data['result'] ?? data['content'];
      if (nested is List) return nested;
    }
    throw Exception('Backend returned an invalid list response');
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Backend returned an invalid object response');
  }

  T _requireData<T>(ApiResponse<T> response) {
    _ensureSuccess(response);
    final data = response.data;
    if (data == null) {
      throw Exception('Backend returned an empty response');
    }
    return data;
  }

  void _ensureSuccess(ApiResponse<dynamic> response) {
    if (!response.isSuccess) {
      throw Exception(
        response.message ?? 'Request failed (${response.statusCode})',
      );
    }
  }
}
