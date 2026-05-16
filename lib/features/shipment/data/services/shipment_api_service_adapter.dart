// lib/features/shipment/data/services/shipment_api_service_adapter.dart
//
// Adapter that connects ShipmentApiService to the new ApiClient

import 'package:memilogistics_app/core/network/api_client.dart';
import 'shipment_api_service.dart';

class ShipmentApiServiceAdapter implements ShipmentApiService {
  final ApiClient _apiClient;

  ShipmentApiServiceAdapter({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<void> createShipment({
    required Map<String, dynamic> body,
    required String accessToken,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/shipments',
      data: body,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (!response.isSuccess) {
      throw Exception(response.message ?? 'Failed to create shipment');
    }
  }
}
