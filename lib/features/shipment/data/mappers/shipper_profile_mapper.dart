// lib/features/shipment/data/mappers/shipper_profile_mapper.dart

import '../../../../core/utils/json_parsing.dart';
import '../../../carrier/data/models/address_model.dart';
import '../../domain/entities/shipper_profile.dart';

class ShipperProfileMapper {
  static ShipperProfile fromJson(Map<String, dynamic> json) {
    return ShipperProfile(
      id: JsonParsing.asInt(json['id']),
      authenticationEmail: JsonParsing.asString(json['authenticationEmail']),
      firstName: JsonParsing.asString(json['firstName']),
      lastName: JsonParsing.asString(json['lastName']),
      companyName: JsonParsing.asString(json['companyName']),
      businessName: JsonParsing.asString(json['businessName']),
      address: AddressModel.fromJson(JsonParsing.asMap(json['address']) ?? {}),
      shipments: JsonParsing.asStringList(json['shipments']),
    );
  }

  static Map<String, dynamic> toJson(ShipperProfile profile) {
    return {
      'id': profile.id,
      'authenticationEmail': profile.authenticationEmail,
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'companyName': profile.companyName,
      'businessName': profile.businessName,
      'address': AddressModel(
        id: profile.address.id,
        street: profile.address.street,
        city: profile.address.city,
        state: profile.address.state,
        zip: profile.address.zip,
        country: profile.address.country,
        phoneNumber: profile.address.phoneNumber,
      ).toJson(),
      'shipments': profile.shipments,
    };
  }
}
