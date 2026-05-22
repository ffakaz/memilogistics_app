// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment_offer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ShipmentOfferModelToJson(ShipmentOfferModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'price': instance.price,
      'shipmentId': instance.shipmentId,
      'shipmentTrackingNumber': instance.shipmentTrackingNumber,
      'carrierCompany': instance.carrierCompany?.toJson(),
    };
