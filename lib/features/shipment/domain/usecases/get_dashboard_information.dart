import '../entities/dashboard_information.dart';
import '../repositories/shipment_repository.dart';

class GetDashboardInformation {
  final ShipmentRepository repository;

  const GetDashboardInformation(this.repository);

  Future<DashboardInformation> call() {
    return repository.getDashboardInformation();
  }
}
