import '../entities/shipment.dart';
import '../entities/dashboard_information.dart';
import '../entities/paginated_shipments.dart';
import '../enums/shipment_status.dart';
import '../../../shipment_offer/data/models/shipment_offer_model.dart';
import '../../data/models/shipment_statistics_model.dart';

abstract class ShipmentRepository {
  Future<Shipment> createShipment(Shipment shipment, {int? shipperId});
  Future<List<Shipment>> listShipments({int page = 0, int size = 20});
  Future<List<Shipment>> getMyShipmentsByStatus({
    required ShipmentStatus status,
    int page = 0,
    int size = 20,
  });
  
  // Paginated methods
  Future<PaginatedShipments> listShipmentsPaginated({int page = 0, int size = 20});
  Future<PaginatedShipments> getShipperShipmentsPaginated({int page = 0, int size = 20});
  
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
  Future<List<ShipmentOfferModel>> getShipmentOffers(int shipmentId);
  Future<ShipmentStatisticsDto> getShipmentStatistics();
  Future<DashboardInformation> getDashboardInformation();
  
  // Carrier-specific shipments
  Future<List<Shipment>> getCarrierAssignedShipments();
  Future<List<Shipment>> getCarrierAssignedShipmentsById(int carrierId);
}
