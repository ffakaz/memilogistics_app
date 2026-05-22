// lib/features/shipment/domain/entities/shipment_event.dart

import '../enums/shipment_status.dart';

/// Shipment event entity representing a tracking event in the shipment lifecycle
class ShipmentEvent {
  final int id;
  final String description;
  final ShipmentStatus shipmentStatus;
  final String location;
  final DateTime eventTimestamp;
  final String shipment;

  const ShipmentEvent({
    required this.id,
    required this.description,
    required this.shipmentStatus,
    required this.location,
    required this.eventTimestamp,
    required this.shipment,
  });

  ShipmentEvent copyWith({
    int? id,
    String? description,
    ShipmentStatus? shipmentStatus,
    String? location,
    DateTime? eventTimestamp,
    String? shipment,
  }) {
    return ShipmentEvent(
      id: id ?? this.id,
      description: description ?? this.description,
      shipmentStatus: shipmentStatus ?? this.shipmentStatus,
      location: location ?? this.location,
      eventTimestamp: eventTimestamp ?? this.eventTimestamp,
      shipment: shipment ?? this.shipment,
    );
  }
}
