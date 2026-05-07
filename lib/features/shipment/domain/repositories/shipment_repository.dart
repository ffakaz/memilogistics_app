abstract class ShipmentRepository {
  /// Accepts a shipment represented as a plain map to avoid tight domain coupling.
  Future<void> createShipment(Map<String, dynamic> shipment);
}