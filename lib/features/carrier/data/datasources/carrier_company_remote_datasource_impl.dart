import 'package:memilogistics_app/core/network/api_client.dart';
import '../models/carrier_company_model.dart';
import 'carrier_company_remote_datasource.dart';

class CarrierCompanyRemoteDataSourceImpl implements CarrierCompanyRemoteDataSource {
  final ApiClient apiClient;

  CarrierCompanyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CarrierCompanyModel> createCarrierCompany(CarrierCompanyModel company) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/carrier/company',
      data: company.toJson(),
    );

    if (response.isSuccess && response.data != null) {
      return CarrierCompanyModel.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Failed to create carrier company');
    }
  }

  @override
  Future<CarrierCompanyModel> getCarrierCompany() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/carrier/company',
    );

    if (response.isSuccess && response.data != null) {
      return CarrierCompanyModel.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Failed to get carrier company');
    }
  }

  @override
  Future<CarrierCompanyModel> updateCarrierCompany(CarrierCompanyModel company) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      '/carrier/company',
      data: company.toJson(),
    );

    if (response.isSuccess && response.data != null) {
      return CarrierCompanyModel.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Failed to update carrier company');
    }
  }
}
