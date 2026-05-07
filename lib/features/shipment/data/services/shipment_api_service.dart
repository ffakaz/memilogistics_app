/// Service interface for shipment API operations.
abstract class ShipmentApiService {
  Future<void> createShipment({
    required Map<String, dynamic> body,
    required String accessToken,
  });
}