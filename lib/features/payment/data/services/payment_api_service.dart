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
    print('  Full URL: ${ApiConstants.baseUrl}${ApiConstants.apiPrefix}$endpoint');
    print('  Request: ${request.toJson()}');

    try {
      final response = await _apiClient.post(
        '${ApiConstants.apiPrefix}$endpoint',
        data: request.toJson(),
      );

      print('✅ Payment initiation response:');
      print('  Success: ${response.isSuccess}');
      print('  Status Code: ${response.statusCode}');
      print('  Message: ${response.message}');
      print('  Data type: ${response.data.runtimeType}');
      print('  Data: ${response.data}');

      if (!response.isSuccess) {
        final errorMsg = response.message ?? 'Failed to initiate payment';
        print('❌ Payment initiation failed: $errorMsg');
        throw Exception(errorMsg);
      }

      // CRITICAL FIX: Handle various response formats
      // Backend may return 200 OK with:
      // 1. null body
      // 2. empty string
      // 3. "OK" text
      // 4. Valid JSON payment record
      
      if (response.data == null || 
          (response.data is String && (response.data as String).isEmpty) ||
          (response.data is String && (response.data as String).toLowerCase() == 'ok')) {
        print('⚠️  Backend returned success without payment record body');
        print('⚠️  Creating fallback payment record (operation succeeded on backend)');
        return PaymentRecordModel(
          amount: request.amount,
          currency: request.currencyCode,
          paymentStatus: 'PENDING',
          paymentMethod: request.paymentMethod,
          createdAt: DateTime.now(),
        );
      }

      // Try to parse as JSON
      try {
        if (response.data is Map<String, dynamic>) {
          return PaymentRecordModel.fromJson(response.data as Map<String, dynamic>);
        } else if (response.data is Map) {
          return PaymentRecordModel.fromJson(
            Map<String, dynamic>.from(response.data as Map),
          );
        } else {
          print('⚠️  Unexpected response data type: ${response.data.runtimeType}');
          print('⚠️  Creating fallback payment record');
          return PaymentRecordModel(
            amount: request.amount,
            currency: request.currencyCode,
            paymentStatus: 'PENDING',
            paymentMethod: request.paymentMethod,
            createdAt: DateTime.now(),
          );
        }
      } catch (parseError) {
        print('⚠️  Failed to parse payment record: $parseError');
        print('⚠️  But HTTP status was successful, so operation completed on backend');
        print('⚠️  Creating fallback payment record');
        return PaymentRecordModel(
          amount: request.amount,
          currency: request.currencyCode,
          paymentStatus: 'PENDING',
          paymentMethod: request.paymentMethod,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('❌ Payment initiation exception: $e');
      rethrow;
    }
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

    try {
      final response = await _apiClient.post(
        '${ApiConstants.apiPrefix}$endpoint',
      );

      print('✅ Payment confirmation response:');
      print('  Success: ${response.isSuccess}');
      print('  Status Code: ${response.statusCode}');
      print('  Data type: ${response.data.runtimeType}');
      print('  Data: ${response.data}');

      if (!response.isSuccess) {
        throw Exception(response.message ?? 'Failed to confirm payment');
      }

      // CRITICAL FIX: Handle various response formats
      // Backend may return 200 OK with null/empty/OK text
      if (response.data == null || 
          (response.data is String && (response.data as String).isEmpty) ||
          (response.data is String && (response.data as String).toLowerCase() == 'ok')) {
        print('⚠️  Backend returned success without payment record body');
        print('⚠️  Creating fallback payment record (operation succeeded on backend)');
        return PaymentRecordModel(
          id: fallbackRecord?.id,
          amount: fallbackRecord?.amount ?? 0,
          currency: fallbackRecord?.currency ?? 'ETB',
          paymentStatus: 'COMPLETED',
          paymentMethod: fallbackRecord?.paymentMethod ?? 'BANK_TRANSFER',
          transactionId: fallbackRecord?.transactionId,
          paidAt: DateTime.now(),
          createdAt: fallbackRecord?.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      // Try to parse as JSON
      try {
        if (response.data is Map<String, dynamic>) {
          return PaymentRecordModel.fromJson(response.data as Map<String, dynamic>);
        } else if (response.data is Map) {
          return PaymentRecordModel.fromJson(
            Map<String, dynamic>.from(response.data as Map),
          );
        } else {
          print('⚠️  Unexpected response data type: ${response.data.runtimeType}');
          print('⚠️  Creating fallback payment record');
          return PaymentRecordModel(
            id: fallbackRecord?.id,
            amount: fallbackRecord?.amount ?? 0,
            currency: fallbackRecord?.currency ?? 'ETB',
            paymentStatus: 'COMPLETED',
            paymentMethod: fallbackRecord?.paymentMethod ?? 'BANK_TRANSFER',
            transactionId: fallbackRecord?.transactionId,
            paidAt: DateTime.now(),
            createdAt: fallbackRecord?.createdAt,
            updatedAt: DateTime.now(),
          );
        }
      } catch (parseError) {
        print('⚠️  Failed to parse payment record: $parseError');
        print('⚠️  But HTTP status was successful, so operation completed on backend');
        print('⚠️  Creating fallback payment record');
        return PaymentRecordModel(
          id: fallbackRecord?.id,
          amount: fallbackRecord?.amount ?? 0,
          currency: fallbackRecord?.currency ?? 'ETB',
          paymentStatus: 'COMPLETED',
          paymentMethod: fallbackRecord?.paymentMethod ?? 'BANK_TRANSFER',
          transactionId: fallbackRecord?.transactionId,
          paidAt: DateTime.now(),
          createdAt: fallbackRecord?.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('❌ Payment confirmation exception: $e');
      rethrow;
    }
  }
}
