import '../entities/carrier_company.dart';
import '../repositories/carrier_company_repository.dart';

class UpdateCarrierCompany {
  final CarrierCompanyRepository repository;

  const UpdateCarrierCompany(this.repository);

  Future<CarrierCompany> call(CarrierCompany company) {
    return repository.updateCarrierCompany(company);
  }
}
