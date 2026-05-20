import '../entities/carrier_company.dart';

abstract class CarrierCompanyRepository {
  Future<CarrierCompany> createCarrierCompany(
    CarrierCompany company,
  );

  Future<CarrierCompany> getCarrierCompany();

  Future<CarrierCompany> updateCarrierCompany(
    CarrierCompany company,
  );
}