// lib/features/shipment/data/mappers/shipment_event_mapper.dart

import '../../domain/entities/shipment_event.dart';
import '../../domain/enums/shipment_status.dart';

class ShipmentEventMapper {
  static ShipmentEvent fromJson(Map<String, dynamic> json) {
    return ShipmentEvent(
      id: json['id'] as int,
      description: json['description'] as String,
      shipmentStatus: _parseStatus(json['shipmentStatus'] as String),
      location: json['location'] as String,
      eventTimestamp: DateTime.parse(json['eventTimestamp'] as String),
      shipment: json['shipment'] as String,
    );
  }

  static Map<String, dynamic> toJson(ShipmentEvent event) {
    return {
      'id': event.id,
      'description': event.description,
      'shipmentStatus': event.shipmentStatus.backendValue,
      'location': event.location,
      'eventTimestamp': event.eventTimestamp.toIso8601String(),
      'shipment': event.shipment,
    };
  }

  static ShipmentStatus _parseStatus(String status) {
    final normalized = status.toUpperCase().replaceAll('-', '_');
    try {
      return ShipmentStatus.values.firstWhere(
        (e) => e.backendValue == normalized,
        orElse: () => ShipmentStatus.pending,
      );
    } catch (e) {
      return ShipmentStatus.pending;
    }
  }
}
