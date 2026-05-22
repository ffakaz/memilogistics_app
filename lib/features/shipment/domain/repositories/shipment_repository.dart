import '../entities/shipment.dart';
import '../entities/dashboard_information.dart';
import '../enums/shipment_status.dart';

abstract class ShipmentRepository {
  Future<Shipment> createShipment(Shipment shipment);
  Future<List<Shipment>> listShipments({int page = 0, int size = 20});
  Future<Shipment> getShipment(int shipmentId);
  Future<void> deleteShipment(int shipmentId);
  Future<void> offerShipment({required int shipmentId, required double price});
  Future<void> cancelShipmentOffer(int shipmentOfferId);
  Future<void> assignCarrier({required int shipmentId, required int carrierId});
  Future<Shipment> updateShipmentStatus({
    required int shipmentId,
    required ShipmentStatus status,
    required String location,
  });
  Future<List<Map<String, dynamic>>> getShipmentEvents(int shipmentId);
  Future<DashboardInformation> getDashboardInformation();
}
