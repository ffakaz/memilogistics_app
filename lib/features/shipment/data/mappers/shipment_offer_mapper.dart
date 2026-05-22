// lib/features/shipment/data/mappers/shipment_offer_mapper.dart

import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/shipment_offer.dart';

class ShipmentOfferMapper {
  static ShipmentOffer fromJson(Map<String, dynamic> json) {
    final carrierCompany = json['carrierCompany'];
    return ShipmentOffer(
      id: JsonParsing.asInt(json['id']),
      createdAt: JsonParsing.asDateTime(json['createdAt']) ?? DateTime.now(),
      price: JsonParsing.asDouble(json['price']),
      carrierCompany: carrierCompany is Map
          ? JsonParsing.asString(
              carrierCompany['companyName'],
              fallback: 'Unknown Carrier',
            )
          : JsonParsing.asString(carrierCompany, fallback: 'Unknown Carrier'),
    );
  }

  static Map<String, dynamic> toJson(ShipmentOffer offer) {
    return {
      'id': offer.id,
      'createdAt': offer.createdAt.toIso8601String(),
      'price': offer.price,
      'carrierCompany': offer.carrierCompany,
    };
  }
}
