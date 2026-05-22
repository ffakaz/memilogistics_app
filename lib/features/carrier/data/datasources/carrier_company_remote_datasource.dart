import '../models/carrier_company_model.dart';

abstract class CarrierCompanyRemoteDataSource {
  Future<CarrierCompanyModel> createCarrierCompany(CarrierCompanyModel company);

  Future<CarrierCompanyModel> getCarrierCompany();

  Future<CarrierCompanyModel> updateCarrierCompany(CarrierCompanyModel company);
}
