import '../entities/carrier_company.dart';
import '../repositories/carrier_company_repository.dart';

class GetCarrierCompany {
  final CarrierCompanyRepository repository;

  const GetCarrierCompany(this.repository);

  Future<CarrierCompany> call() {
    return repository.getCarrierCompany();
  }
}
