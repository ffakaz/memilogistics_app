import 'package:memilogistics_app/core/network/api_client.dart';
import 'package:memilogistics_app/core/utils/constants/api_constants.dart';
import '../models/carrier_company_model.dart';
import 'carrier_company_remote_datasource.dart';

/// Remote datasource for carrier company operations
/// 
/// FUTURE FEATURE: Carrier Company Management
/// 
/// Status: NOT IMPLEMENTED - Endpoints not available in backend
/// 
/// The endpoints used here (/carrier/company) are NOT documented in the
/// backend OpenAPI contract. This is a future feature for managing carrier
/// company profiles, fleet information, and business details.
/// 
/// Current Implementation:
/// - Code structure is ready for future use
/// - CarrierCompanyProvider is registered but not actively used
/// - Carrier dashboard works without these endpoints
/// 
/// Future Implementation Plan:
/// - Coordinate with backend team on endpoint design
/// - Decide if carrier companies should be:
///   * Separate entity with dedicated endpoints
///   * Part of user profile (embedded in user data)
///   * Created during carrier registration
/// - Add company management UI when backend is ready
class CarrierCompanyRemoteDataSourceImpl implements CarrierCompanyRemoteDataSource {
  final ApiClient apiClient;

  CarrierCompanyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CarrierCompanyModel> createCarrierCompany(CarrierCompanyModel company) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.apiPrefix}/carrier/company',
        data: company.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        return CarrierCompanyModel.fromJson(response.data!);
      } else {
        throw Exception(response.message ?? 'Failed to create carrier company');
      }
    } catch (e) {
      // Add context to error for debugging
      throw Exception('Carrier company creation failed: $e. '
          'Note: This endpoint may not exist in the backend.');
    }
  }

  @override
  Future<CarrierCompanyModel> getCarrierCompany() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.apiPrefix}/carrier/company',
      );

      if (response.isSuccess && response.data != null) {
        return CarrierCompanyModel.fromJson(response.data!);
      } else {
        throw Exception(response.message ?? 'Failed to get carrier company');
      }
    } catch (e) {
      // Add context to error for debugging
      throw Exception('Failed to get carrier company: $e. '
          'Note: This endpoint may not exist in the backend.');
    }
  }

  @override
  Future<CarrierCompanyModel> updateCarrierCompany(CarrierCompanyModel company) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.apiPrefix}/carrier/company',
        data: company.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        return CarrierCompanyModel.fromJson(response.data!);
      } else {
        throw Exception(response.message ?? 'Failed to update carrier company');
      }
    } catch (e) {
      // Add context to error for debugging
      throw Exception('Carrier company update failed: $e. '
          'Note: This endpoint may not exist in the backend.');
    }
  }
}
