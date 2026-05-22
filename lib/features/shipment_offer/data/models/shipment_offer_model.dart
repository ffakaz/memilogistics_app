// lib/features/shipment_offer/data/models/shipment_offer_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:memilogistics_app/core/utils/json_parsing.dart';
import 'package:memilogistics_app/features/carrier/data/models/carrier_company_model.dart';

part 'shipment_offer_model.g.dart';

/// ShipmentOffer data model for JSON serialization
/// Matches backend OpenAPI contract: GET /api/shipments/{shipmentId}/offers
@JsonSerializable(createFactory: false, explicitToJson: true)
class ShipmentOfferModel {
  final int id; // int64
  final DateTime createdAt;
  final double price;
  final int shipmentId; // int64 - ADDED to match backend
  final String shipmentTrackingNumber; // ADDED to match backend
  final CarrierCompanyModel? carrierCompany;

  const ShipmentOfferModel({
    required this.id,
    required this.createdAt,
    required this.price,
    required this.shipmentId,
    required this.shipmentTrackingNumber,
    this.carrierCompany,
  });

  factory ShipmentOfferModel.fromJson(Map<String, dynamic> json) {
    return ShipmentOfferModel(
      id: JsonParsing.asInt(json['id']),
      createdAt: JsonParsing.asDateTime(json['createdAt']) ?? DateTime.now(),
      price: JsonParsing.asDouble(json['price']),
      shipmentId: JsonParsing.asInt(json['shipmentId']),
      shipmentTrackingNumber: JsonParsing.asString(
        json['shipmentTrackingNumber'],
      ),
      carrierCompany: JsonParsing.asMap(json['carrierCompany']) == null
          ? null
          : CarrierCompanyModel.fromJson(
              JsonParsing.asMap(json['carrierCompany'])!,
            ),
    );
  }

  Map<String, dynamic> toJson() => _$ShipmentOfferModelToJson(this);
}
