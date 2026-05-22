// lib/features/shipper/data/mappers/shipper_company_mapper.dart

import '../../../carrier/data/mapper/address_mapper.dart';
import '../../domain/entities/shipper_company.dart';
import '../models/shipper_company_model.dart';

/// Shipper Company Mapper
///
/// Maps between ShipperCompany entity (domain) and ShipperCompanyModel (data).
/// Handles the conversion between business logic and API data structures.
class ShipperCompanyMapper {
  /// Converts a ShipperCompanyModel to a ShipperCompany entity
  static ShipperCompany toEntity(ShipperCompanyModel model) {
    return ShipperCompany(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
      companyName: model.companyName,
      businessName: model.businessName,
      companyEmail: model.companyEmail,
      address: AddressMapper.toEntity(model.address),
    );
  }

  /// Converts a ShipperCompany entity to a ShipperCompanyModel
  static ShipperCompanyModel toModel(ShipperCompany entity) {
    return ShipperCompanyModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      companyName: entity.companyName,
      businessName: entity.businessName,
      companyEmail: entity.companyEmail,
      address: AddressMapper.toModel(entity.address),
    );
  }
}
