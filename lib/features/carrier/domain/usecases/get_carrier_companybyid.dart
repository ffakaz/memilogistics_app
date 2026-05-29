import '../entities/carrier_company.dart';
import '../repositories/carrier_company_repository.dart';

/// Usecase to fetch a carrier company by its ID.
class GetCarrierCompanyById {
  final CarrierCompanyRepository repository;

  GetCarrierCompanyById(this.repository);

  Future<CarrierCompany> call(int carrierId) async {
    return await repository.getCarrierCompanyById(carrierId);
  }
}