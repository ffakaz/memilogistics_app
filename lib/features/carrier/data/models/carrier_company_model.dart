import '../../domain/entities/carrier_company.dart';
import '../../../../core/utils/json_parsing.dart';
import 'address_model.dart';

class CarrierCompanyModel extends CarrierCompany {
  const CarrierCompanyModel({
    required super.id,
    required super.companyName,
    required AddressModel address,
    required super.companyEmail,
  }) : super(address: address);

  factory CarrierCompanyModel.fromJson(Map<String, dynamic> json) {
    final addressJson = JsonParsing.asMap(json['address']) ?? json;
    return CarrierCompanyModel(
      id: JsonParsing.asInt(json['id']),
      companyName: JsonParsing.asString(
        json['companyName'] ?? json['businessName'] ?? json['name'],
      ),
      address: AddressModel.fromJson(addressJson),
      companyEmail: JsonParsing.asString(json['companyEmail'] ?? json['email']),
    );
  }

  /// Converts to JSON for API create/update requests (flat structure)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'companyName': companyName,
      'companyEmail': companyEmail,
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'zip': address.zip,
      'country': address.country,
      'phoneNumber': address.phoneNumber,
    };
  }

  Map<String, dynamic> toJsonForUpdate() => toJsonForCreate();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'address': {
        if (address.id != null) 'id': address.id,
        'street': address.street,
        'city': address.city,
        'state': address.state,
        'zip': address.zip,
        'country': address.country,
        'phoneNumber': address.phoneNumber,
      },
      'companyEmail': companyEmail,
    };
  }
}
