// lib/features/shipment/data/models/shipment_response_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../domain/enums/shipment_status.dart';

part 'shipment_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ShipmentResponseModel {
  final int id;
  final String? trackingNumber;
  final String origin;
  final String destination;
  final double weightKg;
  final double? volume;
  
  @JsonKey(unknownEnumValue: ShipmentStatus.pending)
  final ShipmentStatus status;
  
  final DateTime? pickupDate;
  final DateTime? estimatedDeliveryDate;
  final String? shipmentItem;
  final String? description;
  final bool fragile;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  
  // Nested objects - keeping as dynamic for now
  final Map<String, dynamic>? shipper;
  final Map<String, dynamic>? assignedCarrier;
  final List<Map<String, dynamic>>? shipmentOffers;
  final List<Map<String, dynamic>>? shipmentEvents;

  const ShipmentResponseModel({
    required this.id,
    this.trackingNumber,
    required this.origin,
    required this.destination,
    required this.weightKg,
    this.volume,
    required this.status,
    this.pickupDate,
    this.estimatedDeliveryDate,
    this.shipmentItem,
    this.description,
    required this.fragile,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.shipper,
    this.assignedCarrier,
    this.shipmentOffers,
    this.shipmentEvents,
  });

  factory ShipmentResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShipmentResponseModelToJson(this);
}
