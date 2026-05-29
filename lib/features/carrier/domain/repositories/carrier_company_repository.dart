import 'package:memilogistics_app/features/carrier/domain/entities/carrier_company.dart';

abstract class CarrierCompanyRepository {
  Future<CarrierCompany> createCarrierCompany(
    CarrierCompany company,
  );

  Future<CarrierCompany> getCarrierCompany();

  /// Retrieves a carrier company by its ID.
  Future<CarrierCompany> getCarrierCompanyById(int carrierId);

  Future<CarrierCompany> updateCarrierCompany(
    CarrierCompany company,
  );
}