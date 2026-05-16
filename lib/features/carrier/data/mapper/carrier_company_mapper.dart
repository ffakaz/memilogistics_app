import '../../domain/entities/carrier_company.dart';
import '../models/carrier_company_model.dart';
import 'address_mapper.dart';

class CarrierCompanyMapper {
  const CarrierCompanyMapper._();

  static CarrierCompanyModel toModel(CarrierCompany company) {
    return CarrierCompanyModel(
      managerUserId: company.managerUserId,
      companyName: company.companyName,
      companyEmail: company.companyEmail,
      address: AddressMapper.toModel(company.address),
    );
  }

  static CarrierCompany toEntity(CarrierCompanyModel model) {
    return CarrierCompany(
      managerUserId: model.managerUserId,
      companyName: model.companyName,
      companyEmail: model.companyEmail,
      address: AddressMapper.toEntity(model.address),
    );
  }
}
