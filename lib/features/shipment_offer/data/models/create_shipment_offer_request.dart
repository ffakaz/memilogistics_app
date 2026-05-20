// lib/features/shipment_offer/data/models/create_shipment_offer_request.dart

/// Request model for creating a shipment offer
/// 
/// Backend endpoint: POST /api/shipments/{shipmentId}/offer-shipment?price={price}
class CreateShipmentOfferRequest {
  final int shipmentId;
  final double price;

  const CreateShipmentOfferRequest({
    required this.shipmentId,
    required this.price,
  });

  /// Convert to query parameters (price goes in query string)
  Map<String, dynamic> toQueryParameters() {
    return {
      'price': price.toString(),
    };
  }

  @override
  String toString() =>
      'CreateShipmentOfferRequest(shipmentId: $shipmentId, price: $price)';
}
