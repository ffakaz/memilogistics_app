import '../entities/carrier_company.dart';
import '../repositories/carrier_company_repository.dart';

class GetCarrierCompany {
  final CarrierCompanyRepository repository;

  GetCarrierCompany(this.repository);

  Future<CarrierCompany> call() async {
    return await repository.getCarrierCompany();
  }
}
