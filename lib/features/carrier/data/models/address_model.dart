import '../../domain/entities/address.dart';
import '../../../../core/utils/json_parsing.dart';

class AddressModel extends Address {
  const AddressModel({
    int? id,
    required String street,
    required String city,
    required String state,
    required String zip,
    required String country,
    required String phoneNumber,
  }) : super(
         id: id,
         street: street,
         city: city,
         state: state,
         zip: zip,
         country: country,
         phoneNumber: phoneNumber,
       );

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] == null ? null : JsonParsing.asInt(json['id']),
      street: JsonParsing.asString(json['street']),
      city: JsonParsing.asString(json['city']),
      state: JsonParsing.asString(json['state']),
      zip: JsonParsing.asString(json['zip'] ?? json['postalCode']),
      country: JsonParsing.asString(json['country']),
      phoneNumber: JsonParsing.asString(json['phoneNumber'] ?? json['phone']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'phoneNumber': phoneNumber,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}
