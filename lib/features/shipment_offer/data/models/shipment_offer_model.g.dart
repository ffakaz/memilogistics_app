// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment_offer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShipmentOfferModel _$ShipmentOfferModelFromJson(Map<String, dynamic> json) =>
    ShipmentOfferModel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      price: (json['price'] as num).toDouble(),
      shipmentId: (json['shipmentId'] as num).toInt(),
      shipmentTrackingNumber: json['shipmentTrackingNumber'] as String,
      carrierCompany: json['carrierCompany'] == null
          ? null
          : CarrierCompanyModel.fromJson(
              json['carrierCompany'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ShipmentOfferModelToJson(ShipmentOfferModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'price': instance.price,
      'shipmentId': instance.shipmentId,
      'shipmentTrackingNumber': instance.shipmentTrackingNumber,
      'carrierCompany': instance.carrierCompany?.toJson(),
    };
