// lib/features/shipment/data/models/create_shipment_request.dart

/// Request model for creating a new shipment
/// Matches backend API specification
/// 
/// Backend expects:
/// - origin, destination: Location strings
/// - weightKg: Weight in kilograms
/// - deliveryDate: Expected delivery date (format: "2026-05-24")
/// - shipmentItem: Description of items being shipped
/// - description: Optional additional details
/// - fragile: Whether shipment contains fragile items
class CreateShipmentRequest {
  final String origin;
  final String shipmentItem;
  final String destination;
  final double weightKg;
  final String deliveryDate;  // Date string: "2026-05-24"
  final String? description;
  final bool fragile;

  const CreateShipmentRequest({
    required this.origin,
    required this.shipmentItem,
    required this.destination,
    required this.weightKg,
    required this.deliveryDate,
    this.description,
    required this.fragile,
  });

  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'shipmentItem': shipmentItem,
      'destination': destination,
      'weightKg': weightKg,
      'deliveryDate': deliveryDate,
      if (description != null) 'description': description,
      'fragile': fragile,
    };
  }
}

