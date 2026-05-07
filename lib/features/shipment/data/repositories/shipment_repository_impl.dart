import '../../domain/repositories/shipment_repository.dart';
import '../services/shipment_api_service.dart';

class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentApiService apiService;

  ShipmentRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<void> createShipment(Map<String, dynamic> shipment) async {
    // Expecting the caller to provide a properly shaped map.
    await apiService.createShipment(
      body: shipment,
      accessToken: 'YOUR_ACCESS_TOKEN',
    );
  }
}