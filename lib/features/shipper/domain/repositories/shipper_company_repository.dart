// lib/features/shipper/domain/repositories/shipper_company_repository.dart

import '../entities/shipper_company.dart';

/// Shipper Company Repository Interface
///
/// Defines the contract for shipper company data operations.
/// This is implemented in the data layer.
abstract class ShipperCompanyRepository {
  /// Creates a new shipper company profile
  Future<ShipperCompany> createShipperCompany(ShipperCompany company);

  /// Gets the current shipper's company profile
  Future<ShipperCompany> getShipperCompany();

  /// Updates the shipper company profile
  Future<ShipperCompany> updateShipperCompany(ShipperCompany company);
}
