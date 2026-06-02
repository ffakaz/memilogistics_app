// lib/features/shipper/data/datasources/shipper_company_remote_datasource_impl.dart

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/shipper_company_model.dart';
import 'shipper_company_remote_datasource.dart';

/// Remote datasource for shipper company operations
///
/// Shipper Profile Management
///
/// Status: IMPLEMENTED - Connected to backend API
///
/// Endpoints:
/// - POST /api/shippers/profile/create - Create shipper profile
/// - GET /api/shippers/profile/me - Get current shipper profile
/// - GET /api/shippers/profile/{id} - Get shipper profile by ID
/// - PATCH /api/shippers/profile/update - Update shipper profile
///
/// This datasource handles shipper company profile operations including
/// creating, retrieving, and updating shipper company information.
class ShipperCompanyRemoteDataSourceImpl
    implements ShipperCompanyRemoteDataSource {
  final ApiClient apiClient;

  ShipperCompanyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ShipperCompanyModel> createShipperCompany(
    ShipperCompanyModel company,
  ) async {
    try {
      final response = await apiClient.post<dynamic>(
        '${ApiConstants.apiPrefix}${ShipperCompanyEndpoints.create}',
        data: company.toJsonForCreate(),
      );

      if (response.isSuccess) {
        if (response.data == null) return company;
        return ShipperCompanyModel.fromJson(_profileBody(response.data));
      }
      throw Exception(response.message ?? 'Failed to create shipper company');
    } catch (e) {
      throw Exception('Shipper company creation failed: $e');
    }
  }

  @override
  Future<ShipperCompanyModel> getShipperCompany() async {
    try {
      final response = await apiClient.get<dynamic>(
        '${ApiConstants.apiPrefix}${ShipperCompanyEndpoints.get}',
      );

      if (response.statusCode == 404) {
        throw NotFoundException(
          response.message ?? 'Shipper profile not found',
        );
      }

      if (response.isSuccess) {
        return ShipperCompanyModel.fromJson(_profileBody(response.data));
      }
      throw Exception(response.message ?? 'Failed to get shipper company');
    } catch (e) {
      if (e is AppException) {
        // Preserve app exceptions (e.g. 404) so callers can handle missing profile
        rethrow;
      }
      throw Exception('Failed to get shipper company: $e');
    }
  }

  @override
  Future<ShipperCompanyModel> getShipperCompanyById(int shipperId) async {
    try {
      final endpoint = ShipperCompanyEndpoints.getById.replaceFirst(
        '{shipperId}',
        '$shipperId',
      );
      final response = await apiClient.get<dynamic>(
        '${ApiConstants.apiPrefix}$endpoint',
      );

      if (response.isSuccess) {
        return ShipperCompanyModel.fromJson(_profileBody(response.data));
      }
      throw Exception(
        response.message ?? 'Failed to get shipper profile by ID',
      );
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to get shipper profile by ID: $e');
    }
  }

  @override
  Future<ShipperCompanyModel> updateShipperCompany(
    ShipperCompanyModel company,
  ) async {
    try {
      final response = await apiClient.patch<dynamic>(
        '${ApiConstants.apiPrefix}${ShipperCompanyEndpoints.update}',
        data: company.toJsonForUpdate(),
      );

      if (response.isSuccess) {
        if (response.data == null) return company;
        return ShipperCompanyModel.fromJson(_profileBody(response.data));
      }
      throw Exception(response.message ?? 'Failed to update shipper company');
    } catch (e) {
      throw Exception('Shipper company update failed: $e');
    }
  }

  Map<String, dynamic> _profileBody(dynamic data) {
    if (data is Map) {
      final payload = Map<String, dynamic>.from(data);
      final nested = payload['data'] ?? payload['result'] ?? payload['profile'];
      if (nested is Map) return Map<String, dynamic>.from(nested);
      return payload;
    }
    throw Exception('Backend returned an invalid shipper profile response');
  }
}
