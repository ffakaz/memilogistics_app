// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_shipment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateShipmentRequest _$CreateShipmentRequestFromJson(
  Map<String, dynamic> json,
) => CreateShipmentRequest(
  origin: json['origin'] as String,
  destination: json['destination'] as String,
  weightKg: (json['weightKg'] as num).toDouble(),
  deliveryDate: CreateShipmentRequest._dateTimeFromJson(
    json['deliveryDate'] as String,
  ),
  fragile: json['fragile'] as bool,
  shipmentItem: json['shipmentItem'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$CreateShipmentRequestToJson(
  CreateShipmentRequest instance,
) => <String, dynamic>{
  'origin': instance.origin,
  'destination': instance.destination,
  'weightKg': instance.weightKg,
  'deliveryDate': CreateShipmentRequest._dateTimeToJson(instance.deliveryDate),
  'fragile': instance.fragile,
  'shipmentItem': instance.shipmentItem,
  'description': instance.description,
};
