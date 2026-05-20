// lib/features/shipment_offer/data/services/shipment_offer_api_service.dart

import 'package:dio/dio.dart';
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
    try {
      final endpoint = '${ApiConstants.apiPrefix}/shipment-offers/my-offers';
      final response = await _apiClient.get(endpoint);
      
      if (response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => ShipmentOfferModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      // If response is not a list, return empty
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to get offers: $e');
    }
  }

  /// Create a shipment offer
  /// POST /api/shipments/{shipmentId}/offer-shipment?price={price}
  Future<void> createOffer({
    required int shipmentId,
    required double price,
  }) async {
    try {
      final endpoint = '${ApiConstants.apiPrefix}/shipments/$shipmentId/offer-shipment';
      
      await _apiClient.post(
        endpoint,
        queryParameters: {'price': price},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel a shipment offer
  /// POST /api/shipments/{shipmentOfferId}/cancel-shipment-offer
  Future<void> cancelOffer(int shipmentOfferId) async {
    try {
      final endpoint = '${ApiConstants.apiPrefix}/shipments/$shipmentOfferId/cancel-shipment-offer';
      
      await _apiClient.post(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Assign carrier to shipment (accept offer)
  /// POST /api/shipments/{shipmentId}/assign-carrier?carrierId={carrierId}
  Future<void> assignCarrier({
    required int shipmentId,
    required int carrierId,
  }) async {
    try {
      final endpoint = '${ApiConstants.apiPrefix}/shipments/$shipmentId/assign-carrier';
      
      await _apiClient.post(
        endpoint,
        queryParameters: {'carrierId': carrierId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['message'] ?? 'Unknown error';

      switch (statusCode) {
        case 400:
          return Exception('Bad Request: $message');
        case 401:
          return Exception('Unauthorized: $message');
        case 403:
          return Exception('Forbidden: $message');
        case 404:
          return Exception('Not Found: $message');
        case 409:
          return Exception('Conflict: $message');
        case 500:
          return Exception('Server Error: $message');
        default:
          return Exception('Error $statusCode: $message');
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Please check your network.');
    }

    return Exception('Network error: ${error.message}');
  }
}
