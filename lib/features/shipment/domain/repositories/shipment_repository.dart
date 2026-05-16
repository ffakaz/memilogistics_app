import '../entities/shipment.dart';

abstract class ShipmentRepository {
  Future<void> createShipment(Shipment shipment);
}
