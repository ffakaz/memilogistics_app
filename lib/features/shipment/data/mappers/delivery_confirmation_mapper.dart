// lib/features/shipment/data/mappers/delivery_confirmation_mapper.dart

import '../../domain/entities/delivery_confirmation.dart';

class DeliveryConfirmationMapper {
  static DeliveryConfirmation fromJson(Map<String, dynamic> json) {
    return DeliveryConfirmation(
      id: json['id'] as int,
      shipment: json['shipment'] as String,
      carrierConfirmed: json['carrierConfirmed'] as bool,
      shipperConfirmed: json['shipperConfirmed'] as bool,
      carrierConfirmedAt: json['carrierConfirmedAt'] != null
          ? DateTime.parse(json['carrierConfirmedAt'] as String)
          : null,
      shipperConfirmedAt: json['shipperConfirmedAt'] != null
          ? DateTime.parse(json['shipperConfirmedAt'] as String)
          : null,
      note: json['note'] as String?,
    );
  }

  static Map<String, dynamic> toJson(DeliveryConfirmation confirmation) {
    return {
      'id': confirmation.id,
      'shipment': confirmation.shipment,
      'carrierConfirmed': confirmation.carrierConfirmed,
      'shipperConfirmed': confirmation.shipperConfirmed,
      if (confirmation.carrierConfirmedAt != null)
        'carrierConfirmedAt': confirmation.carrierConfirmedAt!
            .toIso8601String(),
      if (confirmation.shipperConfirmedAt != null)
        'shipperConfirmedAt': confirmation.shipperConfirmedAt!
            .toIso8601String(),
      if (confirmation.note != null) 'note': confirmation.note,
    };
  }
}
