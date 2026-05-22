import '../entities/carrier_company.dart';
import '../repositories/carrier_company_repository.dart';

class UpdateCarrierCompany {
  final CarrierCompanyRepository repository;

  UpdateCarrierCompany(this.repository);

  Future<CarrierCompany> call(CarrierCompany company) async {
    return await repository.updateCarrierCompany(company);
  }
}
