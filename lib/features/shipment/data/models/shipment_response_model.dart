// lib/features/shipment/data/models/shipment_response_model.dart

import '../../../../core/utils/json_parsing.dart';
import '../../domain/enums/shipment_status.dart';

class ShipmentResponseModel {
  final int id;
  final String? trackingNumber;
  final String origin;
  final String destination;
  final double weightKg;
  final double? volume;

  final ShipmentStatus status;

  final DateTime? pickupDate;
  final DateTime? estimatedDeliveryDate;
  final String? shipmentItem;
  final String? description;
  final bool fragile;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  // New nested objects
  final Map<String, dynamic>? deliveryConfirmation;
  final Map<String, dynamic>? paymentRecord;

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
    this.deliveryConfirmation,
    this.paymentRecord,
    this.shipper,
    this.assignedCarrier,
    this.shipmentOffers,
    this.shipmentEvents,
  });

  factory ShipmentResponseModel.fromJson(Map<String, dynamic> json) {
    return ShipmentResponseModel(
      id: JsonParsing.asInt(json['id']),
      trackingNumber: json['trackingNumber'] as String?,
      origin: JsonParsing.asString(json['origin']),
      destination: JsonParsing.asString(json['destination']),
      weightKg: JsonParsing.asDouble(json['weightKg']),
      volume: json['volume'] == null
          ? null
          : JsonParsing.asDouble(json['volume']),
      status: _parseStatus(json['status']),
      pickupDate: JsonParsing.asDateTime(json['pickupDate']),
      estimatedDeliveryDate: JsonParsing.asDateTime(
        json['estimatedDeliveryDate'],
      ),
      shipmentItem: json['shipmentItem'] as String?,
      description: json['description'] as String?,
      fragile: JsonParsing.asBool(json['fragile']),
      createdAt: JsonParsing.asDateTime(json['createdAt']),
      updatedAt: JsonParsing.asDateTime(json['updatedAt']),
      completedAt: JsonParsing.asDateTime(json['completedAt']),
      deliveryConfirmation: JsonParsing.asMap(json['deliveryConfirmation']),
      paymentRecord: JsonParsing.asMap(json['paymentRecord']),
      shipper: JsonParsing.asMap(json['shipper']),
      assignedCarrier: JsonParsing.asMap(json['assignedCarrier']),
      shipmentOffers: JsonParsing.asMapList(json['shipmentOffers']),
      shipmentEvents: JsonParsing.asMapList(json['shipmentEvents']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'origin': origin,
      'destination': destination,
      'weightKg': weightKg,
      if (volume != null) 'volume': volume,
      'status': status.backendValue,
      if (pickupDate != null) 'pickupDate': pickupDate!.toIso8601String(),
      if (estimatedDeliveryDate != null)
        'estimatedDeliveryDate': estimatedDeliveryDate!.toIso8601String(),
      if (shipmentItem != null) 'shipmentItem': shipmentItem,
      if (description != null) 'description': description,
      'fragile': fragile,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (deliveryConfirmation != null)
        'deliveryConfirmation': deliveryConfirmation,
      if (paymentRecord != null) 'paymentRecord': paymentRecord,
      if (shipper != null) 'shipper': shipper,
      if (assignedCarrier != null) 'assignedCarrier': assignedCarrier,
      if (shipmentOffers != null) 'shipmentOffers': shipmentOffers,
      if (shipmentEvents != null) 'shipmentEvents': shipmentEvents,
    };
  }

  static ShipmentStatus _parseStatus(dynamic value) {
    final normalized = JsonParsing.asString(
      value,
      fallback: 'PENDING',
    ).toUpperCase().replaceAll('-', '_');
    return ShipmentStatus.values.firstWhere(
      (status) => status.backendValue == normalized,
      orElse: () => ShipmentStatus.pending,
    );
  }
}
