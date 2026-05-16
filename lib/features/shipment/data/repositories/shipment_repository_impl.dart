import '../../domain/entities/shipment.dart';
import '../../domain/repositories/shipment_repository.dart';
import '../../../auth/data/storage/token_storage.dart';
import '../mappers/shipment_mapper.dart';
import '../services/shipment_api_service.dart';

class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentApiService apiService;
  final TokenStorage tokenStorage;

  ShipmentRepositoryImpl({
    required this.apiService,
    required this.tokenStorage,
  });

  @override
  Future<void> createShipment(Shipment shipment) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to create a shipment');
    }

    final model = ShipmentMapper.toModel(shipment);
    await apiService.createShipment(
      body: model.toJson(),
      accessToken: accessToken,
    );
  }
}
