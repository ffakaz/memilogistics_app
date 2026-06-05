// lib/features/shipment/data/services/shipment_api_service_real.dart

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/network/request_builder.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/error/http_error_mapper.dart';
import '../../../shipment_offer/data/models/shipment_offer_model.dart';
import '../models/create_shipment_request.dart';
import '../models/shipment_model.dart';
import '../models/paginated_shipment_response.dart';

class ShipmentApiServiceReal {
  final ApiClient _apiClient;

  ShipmentApiServiceReal(this._apiClient);

  Future<ShipmentModel> createShipment(CreateShipmentRequest request) async {
    // Debug logging
    print('=== CREATE SHIPMENT DEBUG ===');
    print('Endpoint: ${ApiConstants.apiPrefix}${ShipmentEndpoints.create}');
    print('Request payload: ${request.toJson()}');
    
    final response = await _apiClient.post<dynamic>(
      '${ApiConstants.apiPrefix}${ShipmentEndpoints.create}',
      data: request.toJson(),
    );
    
    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
    print('=== END DEBUG ===');
    
    return ShipmentModel.fromJson(_requireMap(response));
  }

  Future<List<ShipmentModel>> listShipments({int page = 0, int size = 20}) async {
    // Use the correct backend endpoint: /api/shipment/list
    // This endpoint supports pagination with page and size query parameters
    try {
      final response = await _apiClient.get<dynamic>(
        '${ApiConstants.apiPrefix}${ShipmentEndpoints.list}',
        queryParameters: {'page': page, 'size': size},
      );
      return _parseShipmentList(response);
    } catch (e) {
      print('❌ Failed to fetch shipments from /api/shipment/list: $e');
      rethrow;
    }
  }

  Future<ShipmentModel> getShipment(int shipmentId) async {
    final endpoint = ShipmentEndpoints.getById.replaceAll('{shipmentId}', shipmentId.toString());
    final response = await _apiClient.get<dynamic>('${ApiConstants.apiPrefix}$endpoint');
    return ShipmentModel.fromJson(_requireMap(response));
  }

  Future<void> deleteShipment(int shipmentId) async {
    final endpoint = ShipmentEndpoints.delete.replaceAll('{shipmentId}', shipmentId.toString());
    final response = await _apiClient.delete<dynamic>('${ApiConstants.apiPrefix}$endpoint');
    _ensureSuccess(response);
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _apiClient.get<Map<String, dynamic>>('${ApiConstants.apiPrefix}${ShipmentEndpoints.dashboard}');
    return _requireData(response);
  }

  Future<PaginatedShipmentResponse> listShipmentsPaginated({int page = 0, int size = 20}) async {
    print('=== LIST SHIPMENTS PAGINATED DEBUG ===');
    print('Requesting page: $page, size: $size');
    
    final endpoints = [
      ShipmentEndpoints.list,
      '/shipment/list',
      '/shipments',
      '/shipment',
    ];

    for (final ep in endpoints) {
      try {
        print('Trying endpoint: ${ApiConstants.apiPrefix}$ep');
        final response = await _apiClient.get<dynamic>(
          '${ApiConstants.apiPrefix}$ep',
          queryParameters: {'page': page, 'size': size},
        );
        
        print('Response status: ${response.statusCode}');
        print('Response data type: ${response.data.runtimeType}');
        print('Response data: ${response.data}');
        
        final data = _requireData(response);
        
        // Check if response is a simple array (not paginated)
        if (data is List) {
          print('Backend returned simple array, converting to paginated format');
          return PaginatedShipmentResponse(
            totalElements: data.length,
            totalPages: 1,
            first: true,
            last: true,
            size: data.length,
            content: data.map((json) => ShipmentModel.fromJson(_asMap(json))).toList(),
            number: 0,
            numberOfElements: data.length,
            empty: data.isEmpty,
          );
        }
        
        // Try to parse as paginated response
        print('Attempting to parse as paginated response');
        return PaginatedShipmentResponse.fromJson(_asMap(data));
      } catch (e) {
        print('Endpoint $ep failed: $e');
        continue;
      }
    }

    print('=== ALL ENDPOINTS FAILED ===');
    throw Exception('Failed to fetch paginated shipments from backend - tried multiple endpoints');
  }

  Future<PaginatedShipmentResponse> getShipperShipmentsPaginated({int page = 0, int size = 20}) async {
    print('=== GET MY SHIPMENTS DEBUG ===');
    print('Requesting page: $page, size: $size');
    print('Endpoint: ${ApiConstants.apiPrefix}${ShipmentEndpoints.my}');
    
    final response = await _apiClient.get<dynamic>(
      '${ApiConstants.apiPrefix}${ShipmentEndpoints.my}',
      queryParameters: {'page': page, 'size': size},
    );
    
    print('Response status: ${response.statusCode}');
    print('Response data type: ${response.data.runtimeType}');
    print('Response data: ${response.data}');
    
    final data = _requireData(response);
    
    // Check if response is a simple array (not paginated)
    if (data is List) {
      print('Backend returned simple array, converting to paginated format');
      return PaginatedShipmentResponse(
        totalElements: data.length,
        totalPages: 1,
        first: true,
        last: true,
        size: data.length,
        content: data.map((json) => ShipmentModel.fromJson(_asMap(json))).toList(),
        number: 0,
        numberOfElements: data.length,
        empty: data.isEmpty,
      );
    }
    
    // Try to parse as paginated response
    print('Attempting to parse as paginated response');
    return PaginatedShipmentResponse.fromJson(_asMap(data));
  }

  /// Get my shipments (role-aware - filtered by JWT token)
  /// Shippers see their created shipments, carriers see assigned shipments
  /// GET /api/shipment/my
  Future<List<ShipmentModel>> getMyShipments({int page = 0, int size = 20}) async {
    try {
      final response = await _apiClient.get<dynamic>(
        '${ApiConstants.apiPrefix}${ShipmentEndpoints.my}',
        queryParameters: {'page': page, 'size': size},
      );
      return _parseShipmentList(response);
    } catch (e) {
      print('❌ Failed to fetch my shipments from /api/shipment/my: $e');
      rethrow;
    }
  }

  /// Get my shipments filtered by status
  /// GET /api/shipment/my/status?status=PENDING
  Future<List<ShipmentModel>> getMyShipmentsByStatus({
    required String status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get<dynamic>(
        '${ApiConstants.apiPrefix}${ShipmentEndpoints.myByStatus}',
        queryParameters: {
          'status': status,
          'page': page,
          'size': size,
        },
      );
      return _parseShipmentList(response);
    } catch (e) {
      print('❌ Failed to fetch my shipments by status from /api/shipment/my/status: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getShipmentStatistics() async {
    final response = await _apiClient.get<dynamic>('${ApiConstants.apiPrefix}${ShipmentEndpoints.dashboard}');
    return _requireMap(response);
  }

  Future<List<Map<String, dynamic>>> getShipmentEvents(int shipmentId) async {
    final endpoint = ShipmentEndpoints.getEvents.replaceAll('{shipmentId}', shipmentId.toString());
    final response = await _apiClient.get<dynamic>('${ApiConstants.apiPrefix}$endpoint');
    return _requireList(response).map(_asMap).toList();
  }

  Future<List<ShipmentOfferModel>> getShipmentOffers(int shipmentId) async {
    print('🔍 [API] Fetching offers for shipment $shipmentId');
    final url = RequestBuilder.buildFullUrl(ApiRoutes.getShipmentOffers, {'shipmentId': shipmentId});
    print('   Endpoint: $url');

    try {
      final response = await _apiClient.get<dynamic>(url);
      
      print('   Response status: ${response.statusCode}');
      print('   Response data type: ${response.data.runtimeType}');
      print('   Response data: ${response.data}');
      
      final offers = _requireList(response).map((json) => ShipmentOfferModel.fromJson(_asMap(json))).toList();
      print('   ✅ Parsed ${offers.length} offers successfully');
      
      return offers;
    } catch (e) {
      print('   ❌ Error fetching offers: $e');
      rethrow;
    }
  }

  /// Fetch shipments assigned to the currently authenticated carrier
  Future<List<ShipmentModel>> getCarrierAssignedShipments() async {
    final response = await _apiClient.get<dynamic>('${ApiConstants.apiPrefix}${CarrierShipmentEndpoints.getAssignedForCurrent}');
    return _requireList(response).map((json) => ShipmentModel.fromJson(_asMap(json))).toList();
  }

  /// Fetch shipments assigned to a specific carrier by ID
  Future<List<ShipmentModel>> getCarrierAssignedShipmentsById(int carrierId) async {
    final endpoint = CarrierShipmentEndpoints.getAssignedForCarrier.replaceAll('{carrierId}', carrierId.toString());
    final response = await _apiClient.get<dynamic>('${ApiConstants.apiPrefix}$endpoint');
    return _requireList(response).map((json) => ShipmentModel.fromJson(_asMap(json))).toList();
  }

  Future<void> offerShipment({required int shipmentId, required double price}) async {
    final url = RequestBuilder.buildFullUrl(
      ApiRoutes.createOffer,
      {'shipmentId': shipmentId},
      queryParameters: {'price': price},
      requiredQueryKeys: ['price'],
    );
    final response = await _apiClient.post<dynamic>(url);
    _ensureSuccess(response);
  }

  Future<void> cancelShipmentOffer(int shipmentOfferId) async {
    // OpenAPI: POST /api/shipments/{shipmentOfferId}/cancel-shipment-offer
    // Log the endpoint and parameters for debugging 400 errors
    print('🔵 [API] cancelShipmentOffer called');
    print('   shipmentOfferId: $shipmentOfferId');
    print('   Endpoint template: ${ApiRoutes.cancelOffer}');
    
    final url = RequestBuilder.buildFullUrl(ApiRoutes.cancelOffer, {'shipmentOfferId': shipmentOfferId});
    print('   Built URL: $url');
    
    try {
      final response = await _apiClient.post<dynamic>(url);
      print('   Response status: ${response.statusCode}');
      print('   Response data: ${response.data}');
      _ensureSuccess(response);
      print('   ✅ cancelShipmentOffer succeeded for shipmentOfferId=$shipmentOfferId');
    } catch (e) {
      print('   ❌ cancelShipmentOffer failed for shipmentOfferId=$shipmentOfferId');
      print('   Error: $e');
      print('   Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<void> assignCarrier({required int shipmentId, required int carrierId}) async {
    // OpenAPI: POST /api/shipments/{shipmentId}/assign-carrier?carrierId={carrierId}
    final url = RequestBuilder.buildFullUrl(
      ApiRoutes.assignCarrier,
      {'shipmentId': shipmentId},
      queryParameters: {'carrierId': carrierId},
      requiredQueryKeys: ['carrierId'],
    );
    print('🔵 [API] assignCarrier -> POST $url');
    try {
      final response = await _apiClient.post<dynamic>(url);
      print('   Response status: ${response.statusCode}');
      print('   Response data: ${response.data}');
      _ensureSuccess(response);
      print('   ✅ assignCarrier succeeded for shipmentId=$shipmentId');
    } catch (e) {
      print('   ❌ assignCarrier failed for shipmentId=$shipmentId: $e');
      rethrow;
    }
  }

  Future<ShipmentModel> updateStatus({required int shipmentId, required String location, required String status}) async {
    final url = RequestBuilder.buildFullUrl(
      ShipmentEndpoints.updateStatus,
      {'shipmentId': shipmentId},
    );
    final response = await _apiClient.patch<dynamic>(url, data: {'location': location, 'status': status});
    return ShipmentModel.fromJson(_requireMap(response));
  }

  List<ShipmentModel> _parseShipmentList(ApiResponse<dynamic> response) {
    return _requireList(response).map((json) => ShipmentModel.fromJson(_asMap(json))).toList();
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
      throw HttpErrorMapper.map(response.statusCode, response.message);
    }
  }
}
