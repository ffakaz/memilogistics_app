// lib/features/shipment_offer/data/models/shipment_offer_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:memilogistics_app/core/utils/json_parsing.dart';
import 'package:memilogistics_app/features/carrier/data/models/carrier_company_model.dart';

part 'shipment_offer_model.g.dart';

/// ShipmentOffer data model for JSON serialization
/// Matches backend OpenAPI contract: GET /api/shipment/{shipmentId}/offers
/// 
/// Backend response structure:
/// {
///   "id": 0,
///   "createdAt": "2026-05-27T06:26:30.468Z",
///   "price": 0,
///   "shipmentId": 0,
///   "shipmentTrackingNumber": "string",
///   "carrierCompanyId": 0
/// }
@JsonSerializable(createFactory: false, explicitToJson: true)
class ShipmentOfferModel {
  final int id; // int64
  final DateTime createdAt;
  final double price;
  final int shipmentId; // int64
  final String shipmentTrackingNumber;
  final int? carrierCompanyId; // Backend uses carrierCompanyId, not nested object
  final CarrierCompanyModel? carrierCompany; // For backward compatibility

  const ShipmentOfferModel({
    required this.id,
    required this.createdAt,
    required this.price,
    required this.shipmentId,
    required this.shipmentTrackingNumber,
    this.carrierCompanyId,
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
      carrierCompanyId: JsonParsing.asIntOrNull(json['carrierCompanyId']),
      // Try to parse nested carrierCompany object if present (for backward compatibility)
      carrierCompany: JsonParsing.asMap(json['carrierCompany']) == null
          ? null
          : CarrierCompanyModel.fromJson(
              JsonParsing.asMap(json['carrierCompany'])!,
            ),
    );
  }

  Map<String, dynamic> toJson() => _$ShipmentOfferModelToJson(this);
}
