// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShipmentResponseModel _$ShipmentResponseModelFromJson(
  Map<String, dynamic> json,
) => ShipmentResponseModel(
  id: (json['id'] as num).toInt(),
  trackingNumber: json['trackingNumber'] as String?,
  origin: json['origin'] as String,
  destination: json['destination'] as String,
  weightKg: (json['weightKg'] as num).toDouble(),
  volume: (json['volume'] as num?)?.toDouble(),
  status: $enumDecode(
    _$ShipmentStatusEnumMap,
    json['status'],
    unknownValue: ShipmentStatus.pending,
  ),
  pickupDate: json['pickupDate'] == null
      ? null
      : DateTime.parse(json['pickupDate'] as String),
  estimatedDeliveryDate: json['estimatedDeliveryDate'] == null
      ? null
      : DateTime.parse(json['estimatedDeliveryDate'] as String),
  shipmentItem: json['shipmentItem'] as String?,
  description: json['description'] as String?,
  fragile: json['fragile'] as bool,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  shipper: json['shipper'] as Map<String, dynamic>?,
  assignedCarrier: json['assignedCarrier'] as Map<String, dynamic>?,
  shipmentOffers: (json['shipmentOffers'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  shipmentEvents: (json['shipmentEvents'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$ShipmentResponseModelToJson(
  ShipmentResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'trackingNumber': instance.trackingNumber,
  'origin': instance.origin,
  'destination': instance.destination,
  'weightKg': instance.weightKg,
  'volume': instance.volume,
  'status': _$ShipmentStatusEnumMap[instance.status]!,
  'pickupDate': instance.pickupDate?.toIso8601String(),
  'estimatedDeliveryDate': instance.estimatedDeliveryDate?.toIso8601String(),
  'shipmentItem': instance.shipmentItem,
  'description': instance.description,
  'fragile': instance.fragile,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'shipper': instance.shipper,
  'assignedCarrier': instance.assignedCarrier,
  'shipmentOffers': instance.shipmentOffers,
  'shipmentEvents': instance.shipmentEvents,
};

const _$ShipmentStatusEnumMap = {
  ShipmentStatus.pending: 'PENDING',
  ShipmentStatus.accepted: 'ACCEPTED',
  ShipmentStatus.assigned: 'ASSIGNED',
  ShipmentStatus.pickedUp: 'PICKED_UP',
  ShipmentStatus.inTransit: 'IN_TRANSIT',
  ShipmentStatus.arrivedAtDestination: 'ARRIVED_AT_DESTINATION',
  ShipmentStatus.delivered: 'DELIVERED',
  ShipmentStatus.completed: 'COMPLETED',
  ShipmentStatus.cancelled: 'CANCELLED',
};
