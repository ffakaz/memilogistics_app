/// Create Shipment Request Model
/// Matches backend API: POST /api/shipments/create
/// Only 5 fields required by backend
class ShipmentRequestModel {
  final String origin;
  final String destination;
  final double weightKg;
  final String deliveryDate; // Format: YYYY-MM-DD (date only)
  final bool fragile;

  ShipmentRequestModel({
    required this.origin,
    required this.destination,
    required this.weightKg,
    required this.deliveryDate,
    required this.fragile,
  });

  Map<String, dynamic> toJson() {
    return {
      "origin": origin,
      "destination": destination,
      "weightKg": weightKg,
      "deliveryDate": deliveryDate, // Must be YYYY-MM-DD format
      "fragile": fragile,
    };
  }
}