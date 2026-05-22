import 'package:memilogistics_app/core/network/api_client.dart';
import 'package:memilogistics_app/core/utils/constants/api_constants.dart';
import '../models/carrier_company_model.dart';
import 'carrier_company_remote_datasource.dart';

/// Remote datasource for carrier company operations
///
/// Carrier Profile Management
///
/// Status: IMPLEMENTED - Connected to backend API
///
/// Endpoints:
/// - POST /api/carriers/profile/create - Create carrier profile
/// - GET /api/carriers/profile/me - Get current carrier profile
/// - PATCH /api/carriers/profile/update - Update carrier profile
///
/// This datasource handles carrier company profile operations including
/// creating, retrieving, and updating carrier company information.
class CarrierCompanyRemoteDataSourceImpl
    implements CarrierCompanyRemoteDataSource {
  final ApiClient apiClient;

  CarrierCompanyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CarrierCompanyModel> createCarrierCompany(
    CarrierCompanyModel company,
  ) async {
    try {
      final response = await apiClient.post<dynamic>(
        '${ApiConstants.apiPrefix}${CarrierCompanyEndpoints.create}',
        data: company.toJsonForCreate(),
      );

      if (response.isSuccess) {
        if (response.data == null) return company;
        return CarrierCompanyModel.fromJson(_profileBody(response.data));
      }
      throw Exception(response.message ?? 'Failed to create carrier company');
    } catch (e) {
      throw Exception('Carrier company creation failed: $e');
    }
  }

  @override
  Future<CarrierCompanyModel> getCarrierCompany() async {
    try {
      final response = await apiClient.get<dynamic>(
        '${ApiConstants.apiPrefix}${CarrierCompanyEndpoints.get}',
      );

      if (response.isSuccess) {
        return CarrierCompanyModel.fromJson(_profileBody(response.data));
      }
      throw Exception(response.message ?? 'Failed to get carrier company');
    } catch (e) {
      throw Exception('Failed to get carrier company: $e');
    }
  }

  @override
  Future<CarrierCompanyModel> updateCarrierCompany(
    CarrierCompanyModel company,
  ) async {
    try {
      final response = await apiClient.patch<dynamic>(
        '${ApiConstants.apiPrefix}${CarrierCompanyEndpoints.update}',
        data: company.toJsonForUpdate(),
      );

      if (response.isSuccess) {
        if (response.data == null) return company;
        return CarrierCompanyModel.fromJson(_profileBody(response.data));
      }
      throw Exception(response.message ?? 'Failed to update carrier company');
    } catch (e) {
      throw Exception('Carrier company update failed: $e');
    }
  }

  Map<String, dynamic> _profileBody(dynamic data) {
    if (data is Map) {
      final payload = Map<String, dynamic>.from(data);
      final nested = payload['data'] ?? payload['result'] ?? payload['profile'];
      if (nested is Map) return Map<String, dynamic>.from(nested);
      return payload;
    }
    throw Exception('Backend returned an invalid carrier profile response');
  }
}
