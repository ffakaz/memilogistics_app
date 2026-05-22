// lib/features/shipper/data/repositories/shipper_company_repository_impl.dart

import '../../domain/entities/shipper_company.dart';
import '../../domain/repositories/shipper_company_repository.dart';
import '../datasources/shipper_company_remote_datasource.dart';
import '../mappers/shipper_company_mapper.dart';

/// Shipper Company Repository Implementation
///
/// Implements the repository interface defined in the domain layer.
/// Coordinates between the data source and domain layer using mappers.
class ShipperCompanyRepositoryImpl implements ShipperCompanyRepository {
  final ShipperCompanyRemoteDataSource remoteDataSource;

  ShipperCompanyRepositoryImpl(this.remoteDataSource);

  @override
  Future<ShipperCompany> createShipperCompany(ShipperCompany company) async {
    final model = ShipperCompanyMapper.toModel(company);
    final result = await remoteDataSource.createShipperCompany(model);
    return ShipperCompanyMapper.toEntity(result);
  }

  @override
  Future<ShipperCompany> getShipperCompany() async {
    final result = await remoteDataSource.getShipperCompany();
    return ShipperCompanyMapper.toEntity(result);
  }

  @override
  Future<ShipperCompany> updateShipperCompany(ShipperCompany company) async {
    final model = ShipperCompanyMapper.toModel(company);
    final result = await remoteDataSource.updateShipperCompany(model);
    return ShipperCompanyMapper.toEntity(result);
  }
}
