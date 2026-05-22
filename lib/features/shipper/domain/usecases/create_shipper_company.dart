// lib/features/shipper/domain/usecases/create_shipper_company.dart

import '../entities/shipper_company.dart';
import '../repositories/shipper_company_repository.dart';

/// Use Case: Create Shipper Company
///
/// Creates a new shipper company profile.
/// This is called when a shipper first registers and needs to complete their profile.
class CreateShipperCompany {
  final ShipperCompanyRepository repository;

  CreateShipperCompany(this.repository);

  Future<ShipperCompany> call(ShipperCompany company) async {
    return await repository.createShipperCompany(company);
  }
}
