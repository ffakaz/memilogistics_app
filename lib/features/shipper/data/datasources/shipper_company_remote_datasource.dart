// lib/features/shipper/data/datasources/shipper_company_remote_datasource.dart

import '../models/shipper_company_model.dart';

/// Shipper Company Remote Data Source Interface
///
/// Defines the contract for remote shipper company data operations.
abstract class ShipperCompanyRemoteDataSource {
  /// Creates a new shipper company profile
  Future<ShipperCompanyModel> createShipperCompany(ShipperCompanyModel company);

  /// Gets the current shipper's company profile
  Future<ShipperCompanyModel> getShipperCompany();

  /// Gets a shipper's company profile by ID
  /// 
  /// [shipperId] - The ID of the shipper whose profile to retrieve
  Future<ShipperCompanyModel> getShipperCompanyById(int shipperId);

  /// Updates the shipper company profile
  Future<ShipperCompanyModel> updateShipperCompany(ShipperCompanyModel company);
}
