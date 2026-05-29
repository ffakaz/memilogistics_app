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
  /// POST /api/payment/{shipmentId}/initiate-payment
  Future<PaymentRecordModel> initiatePayment({
    required int shipmentId,
    required PaymentRequestModel request,
  }) async {
    final endpoint = ShipmentEndpoints.initiatePayment.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );

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

    if (!response.isSuccess) {
      throw Exception(response.message ?? 'Failed to initiate payment');
    }

    if (response.data == null) {
      return PaymentRecordModel(
        amount: request.amount,
        currency: request.currencyCode,
        paymentStatus: 'PENDING',
        paymentMethod: request.paymentMethod,
        createdAt: DateTime.now(),
      );
    }

    return PaymentRecordModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Confirm payment completion
  /// POST /api/payment/{shipmentId}/confirm-payment
  /// Note: Backend doesn't require request body based on API docs
  Future<PaymentRecordModel> confirmPayment({
    required int shipmentId,
    PaymentRecordModel? fallbackRecord,
  }) async {
    final endpoint = ShipmentEndpoints.confirmPayment.replaceAll(
      '{shipmentId}',
      shipmentId.toString(),
    );

    print('🔵 Confirming payment for shipment $shipmentId');
    print('  Endpoint: ${ApiConstants.apiPrefix}$endpoint');

    final response = await _apiClient.post(
      '${ApiConstants.apiPrefix}$endpoint',
    );

    print('✅ Payment confirmation response:');
    print('  Success: ${response.isSuccess}');
    print('  Status Code: ${response.statusCode}');
    print('  Data: ${response.data}');

    if (!response.isSuccess) {
      throw Exception(response.message ?? 'Failed to confirm payment');
    }

    if (response.data == null) {
      return PaymentRecordModel(
        id: fallbackRecord?.id,
        amount: fallbackRecord?.amount ?? 0,
        currency: fallbackRecord?.currency ?? 'USD',
        paymentStatus: 'COMPLETED',
        paymentMethod: fallbackRecord?.paymentMethod ?? 'BANK_TRANSFER',
        transactionId: fallbackRecord?.transactionId,
        paidAt: DateTime.now(),
        createdAt: fallbackRecord?.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    return PaymentRecordModel.fromJson(response.data as Map<String, dynamic>);
  }
}
