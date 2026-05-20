// lib/features/shipment_offer/domain/entities/shipment_offer.dart

import 'package:memilogistics_app/features/carrier/domain/entities/carrier_company.dart';

/// ShipmentOffer entity matching backend contract
/// 
/// Backend structure:
/// ```json
/// {
///   "id": 123,
///   "createdAt": "2024-01-15T10:30:00Z",
///   "price": 1500.00,
///   "shipmentId": 456,
///   "shipmentTrackingNumber": "SHIP-2024-001",
///   "carrierCompany": {...}
/// }
/// ```
class ShipmentOffer {
  final int id;
  final DateTime createdAt;
  final double price;
  final int shipmentId; // ADDED to match backend
  final String shipmentTrackingNumber; // ADDED to match backend
  final CarrierCompany? carrierCompany;

  const ShipmentOffer({
    required this.id,
    required this.createdAt,
    required this.price,
    required this.shipmentId,
    required this.shipmentTrackingNumber,
    this.carrierCompany,
  });

  ShipmentOffer copyWith({
    int? id,
    DateTime? createdAt,
    double? price,
    int? shipmentId,
    String? shipmentTrackingNumber,
    CarrierCompany? carrierCompany,
  }) {
    return ShipmentOffer(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      shipmentId: shipmentId ?? this.shipmentId,
      shipmentTrackingNumber: shipmentTrackingNumber ?? this.shipmentTrackingNumber,
      carrierCompany: carrierCompany ?? this.carrierCompany,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShipmentOffer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ShipmentOffer(id: $id, shipmentId: $shipmentId, price: $price, createdAt: $createdAt)';
}
