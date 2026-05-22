// lib/features/shipment/domain/entities/delivery_confirmation.dart

/// Delivery confirmation entity tracking confirmation status from both parties
class DeliveryConfirmation {
  final int id;
  final String shipment;
  final bool carrierConfirmed;
  final bool shipperConfirmed;
  final DateTime? carrierConfirmedAt;
  final DateTime? shipperConfirmedAt;
  final String? note;

  const DeliveryConfirmation({
    required this.id,
    required this.shipment,
    required this.carrierConfirmed,
    required this.shipperConfirmed,
    this.carrierConfirmedAt,
    this.shipperConfirmedAt,
    this.note,
  });

  bool get isFullyConfirmed => carrierConfirmed && shipperConfirmed;

  DeliveryConfirmation copyWith({
    int? id,
    String? shipment,
    bool? carrierConfirmed,
    bool? shipperConfirmed,
    DateTime? carrierConfirmedAt,
    DateTime? shipperConfirmedAt,
    String? note,
  }) {
    return DeliveryConfirmation(
      id: id ?? this.id,
      shipment: shipment ?? this.shipment,
      carrierConfirmed: carrierConfirmed ?? this.carrierConfirmed,
      shipperConfirmed: shipperConfirmed ?? this.shipperConfirmed,
      carrierConfirmedAt: carrierConfirmedAt ?? this.carrierConfirmedAt,
      shipperConfirmedAt: shipperConfirmedAt ?? this.shipperConfirmedAt,
      note: note ?? this.note,
    );
  }
}
