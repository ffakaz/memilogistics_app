// lib/features/payment/data/services/payment_api_service.dart

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../models/payment_record_model.dart';
import '../models/payment_request_model.dart';

/// Payment API service
/// Handles HTTP requests to payment endpoints
/// Based on actual backend API (only 2 endpoints confirmed)
class PaymentApiService {
  final ApiClient _apiClient;

  PaymentApiService(this._apiClient);

  /// Initiate payment for a shipment
  /// POST /api/shipments/{shipmentId}/initiate-payment
  Future<PaymentRecordModel> initiatePayment({
    required int shipmentId,
    required PaymentRequestModel request,
  }) async {
    final endpoint = ShipmentEndpoints.initiatePayment
        .replaceAll('{shipmentId}', shipmentId.toString());

    print('🔵 Initiating payment for shipment $shipmentId');
    print('  Endpoint: ${ApiConstants.apiPrefix}$endpoint');
    print('  Request: ${request.toJson()}');

    final response = await _apiClient.post(
      '${ApiConstants.apiPrefix}$endpoint',
      data: request.toJson(),
    );

    print('✅ Payment initiation response:');
    print('  Success: ${response.isSuccess}');
    print('  Status Code: ${response.statusCode}');
    print('  Data: ${response.data}');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message ?? 'Failed to initiate payment');
    }

    return PaymentRecordModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Confirm payment completion
  /// POST /api/shipments/{shipmentId}/confirm-payment
  /// Note: Backend doesn't require request body based on API docs
  Future<PaymentRecordModel> confirmPayment({
    required int shipmentId,
  }) async {
    final endpoint = ShipmentEndpoints.confirmPayment
        .replaceAll('{shipmentId}', shipmentId.toString());

    print('🔵 Confirming payment for shipment $shipmentId');
    print('  Endpoint: ${ApiConstants.apiPrefix}$endpoint');

    final response = await _apiClient.post(
      '${ApiConstants.apiPrefix}$endpoint',
      data: {}, // Empty body as per API docs
    );

    print('✅ Payment confirmation response:');
    print('  Success: ${response.isSuccess}');
    print('  Status Code: ${response.statusCode}');
    print('  Data: ${response.data}');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message ?? 'Failed to confirm payment');
    }

    return PaymentRecordModel.fromJson(response.data as Map<String, dynamic>);
  }
}
