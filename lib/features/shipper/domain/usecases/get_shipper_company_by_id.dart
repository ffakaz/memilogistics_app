// lib/features/shipper/domain/usecases/get_shipper_company_by_id.dart

import '../entities/shipper_company.dart';
import '../repositories/shipper_company_repository.dart';

/// Use Case: Get Shipper Company by ID
///
/// Retrieves a specific shipper's company profile by their ID.
/// Useful for viewing other shippers' profiles or retrieving a specific shipper's information.
class GetShipperCompanyById {
  final ShipperCompanyRepository repository;

  GetShipperCompanyById(this.repository);

  Future<ShipperCompany> call(int shipperId) async {
    return await repository.getShipperCompanyById(shipperId);
  }
}
