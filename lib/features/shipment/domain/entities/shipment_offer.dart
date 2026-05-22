// lib/features/shipment/domain/entities/shipment_offer.dart

/// Shipment offer entity representing a carrier's bid on a shipment
class ShipmentOffer {
  final int id;
  final DateTime createdAt;
  final double price;
  final String carrierCompany;

  const ShipmentOffer({
    required this.id,
    required this.createdAt,
    required this.price,
    required this.carrierCompany,
  });

  ShipmentOffer copyWith({
    int? id,
    DateTime? createdAt,
    double? price,
    String? carrierCompany,
  }) {
    return ShipmentOffer(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      carrierCompany: carrierCompany ?? this.carrierCompany,
    );
  }
}
