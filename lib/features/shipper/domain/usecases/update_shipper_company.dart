// lib/features/shipper/domain/usecases/update_shipper_company.dart

import '../entities/shipper_company.dart';
import '../repositories/shipper_company_repository.dart';

/// Use Case: Update Shipper Company
///
/// Updates an existing shipper company profile.
/// Used when shippers want to edit their company information.
class UpdateShipperCompany {
  final ShipperCompanyRepository repository;

  UpdateShipperCompany(this.repository);

  Future<ShipperCompany> call(ShipperCompany company) async {
    return await repository.updateShipperCompany(company);
  }
}
