import '../entities/carrier_company.dart';
import '../repositories/carrier_company_repository.dart';

class CreateCarrierCompany {
  final CarrierCompanyRepository repository;

  const CreateCarrierCompany(this.repository);

  Future<CarrierCompany> call(CarrierCompany company) {
    return repository.createCarrierCompany(company);
  }
}
