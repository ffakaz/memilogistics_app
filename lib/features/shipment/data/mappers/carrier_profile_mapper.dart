// lib/features/shipment/data/mappers/carrier_profile_mapper.dart

import '../../../../core/utils/json_parsing.dart';
import '../../../carrier/data/models/address_model.dart';
import '../../domain/entities/carrier_profile.dart';
import 'shipment_offer_mapper.dart';

class CarrierProfileMapper {
  static CarrierProfile fromJson(Map<String, dynamic> json) {
    return CarrierProfile(
      id: JsonParsing.asInt(json['id']),
      managerUserId: JsonParsing.asString(json['managerUserId']),
      companyName: JsonParsing.asString(json['companyName']),
      address: AddressModel.fromJson(JsonParsing.asMap(json['address']) ?? {}),
      authenticationEmail: JsonParsing.asString(json['authenticationEmail']),
      companyEmail: JsonParsing.asString(json['companyEmail']),
      assignedShipments: JsonParsing.asStringList(json['assignedShipments']),
      offeredShipments:
          (json['offeredShipments'] as List<dynamic>?)
              ?.map(JsonParsing.asMap)
              .whereType<Map<String, dynamic>>()
              .map(ShipmentOfferMapper.fromJson)
              .toList() ??
          [],
    );
  }

  static Map<String, dynamic> toJson(CarrierProfile profile) {
    return {
      'id': profile.id,
      'managerUserId': profile.managerUserId,
      'companyName': profile.companyName,
      'address': AddressModel(
        id: profile.address.id,
        street: profile.address.street,
        city: profile.address.city,
        state: profile.address.state,
        zip: profile.address.zip,
        country: profile.address.country,
        phoneNumber: profile.address.phoneNumber,
      ).toJson(),
      'authenticationEmail': profile.authenticationEmail,
      'companyEmail': profile.companyEmail,
      'assignedShipments': profile.assignedShipments,
      'offeredShipments': profile.offeredShipments
          .map((offer) => ShipmentOfferMapper.toJson(offer))
          .toList(),
    };
  }
}
