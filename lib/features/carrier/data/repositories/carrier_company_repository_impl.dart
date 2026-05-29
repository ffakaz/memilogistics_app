import 'package:memilogistics_app/features/carrier/domain/entities/carrier_company.dart';
import 'package:memilogistics_app/features/carrier/domain/repositories/carrier_company_repository.dart';

import '../datasources/carrier_company_remote_datasource_impl.dart';
import '../mapper/carrier_company_mapper.dart';

class CarrierCompanyRepositoryImpl implements CarrierCompanyRepository {
  final CarrierCompanyRemoteDataSourceImpl remoteDataSource;

  CarrierCompanyRepositoryImpl(this.remoteDataSource);

  @override
  Future<CarrierCompany> createCarrierCompany(CarrierCompany company) async {
    final model = CarrierCompanyMapper.toModel(company);

    final result = await remoteDataSource.createCarrierCompany(model);

    return CarrierCompanyMapper.toEntity(result);
  }

  @override
  Future<CarrierCompany> getCarrierCompany() async {
    final result = await remoteDataSource.getCarrierCompany();

    return CarrierCompanyMapper.toEntity(result);
  }
@override
  Future<CarrierCompany> getCarrierCompanyById(int carrierId) async {
    final result = await remoteDataSource.getCarrierCompanyById(carrierId);
    return CarrierCompanyMapper.toEntity(result);
  }

  @override
  Future<CarrierCompany> updateCarrierCompany(CarrierCompany company) async {
    final model = CarrierCompanyMapper.toModel(company);

    final result = await remoteDataSource.updateCarrierCompany(model);

    return CarrierCompanyMapper.toEntity(result);
  }
}
