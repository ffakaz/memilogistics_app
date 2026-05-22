// lib/features/shipper/domain/usecases/get_shipper_company.dart

import '../entities/shipper_company.dart';
import '../repositories/shipper_company_repository.dart';

/// Use Case: Get Shipper Company
///
/// Retrieves the current shipper's company profile.
/// Returns 404 if no profile exists (expected for new shippers).
class GetShipperCompany {
  final ShipperCompanyRepository repository;

  GetShipperCompany(this.repository);

  Future<ShipperCompany> call() async {
    return await repository.getShipperCompany();
  }
}
