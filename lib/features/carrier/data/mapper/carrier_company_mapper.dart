import '../../domain/entities/carrier_company.dart';

import '../models/carrier_company_model.dart';
import '../models/address_model.dart';

class CarrierCompanyMapper {
  static CarrierCompanyModel toModel(CarrierCompany entity) {
    return CarrierCompanyModel(
      id: entity.id,
      companyName: entity.companyName,

      address: AddressModel(
        id: entity.address.id,
        street: entity.address.street,
        city: entity.address.city,
        state: entity.address.state,
        zip: entity.address.zip,
        country: entity.address.country,
        phoneNumber: entity.address.phoneNumber,
      ),

      companyEmail: entity.companyEmail,
    );
  }

  static CarrierCompany toEntity(CarrierCompanyModel model) {
    return CarrierCompany(
      id: model.id,
      companyName: model.companyName,
      address: model.address,
      companyEmail: model.companyEmail,
    );
  }
}
