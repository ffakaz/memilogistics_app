// lib/features/shipper/data/models/shipper_company_model.dart

import '../../../carrier/data/models/address_model.dart';
import '../../../../core/utils/json_parsing.dart';

/// Shipper Company Model
///
/// Data model for shipper company that matches the backend API structure.
/// Used for JSON serialization/deserialization.
class ShipperCompanyModel {
  final int id;
  final String firstName;
  final String lastName;
  final String companyName;
  final String businessName;
  final String companyEmail;
  final AddressModel address;

  ShipperCompanyModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.businessName,
    required this.companyEmail,
    required this.address,
  });

  /// Creates a model from JSON (API response)
  factory ShipperCompanyModel.fromJson(Map<String, dynamic> json) {
    final addressJson = JsonParsing.asMap(json['address']) ?? json;
    final companyName = JsonParsing.asString(
      json['companyName'] ?? json['businessName'] ?? json['name'],
    );
    return ShipperCompanyModel(
      id: JsonParsing.asInt(json['id']),
      firstName: JsonParsing.asString(json['firstName']),
      lastName: JsonParsing.asString(json['lastName']),
      companyName: companyName,
      businessName: JsonParsing.asString(
        json['businessName'],
        fallback: companyName,
      ),
      companyEmail: JsonParsing.asString(json['companyEmail'] ?? json['email']),
      address: AddressModel.fromJson(addressJson),
    );
  }

  /// Converts model to JSON for API requests (CREATE)
  /// Uses flat structure for POST requests
  Map<String, dynamic> toJsonForCreate() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'companyName': companyName,
      'businessName': businessName,
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'zip': address.zip,
      'country': address.country,
      'phoneNumber': address.phoneNumber,
    };
  }

  /// Converts model to JSON for API requests (UPDATE)
  /// Uses flat structure for PATCH requests
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'companyName': companyName,
      'businessName': businessName,
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'zip': address.zip,
      'country': address.country,
      'phoneNumber': address.phoneNumber,
    };
  }

  @override
  String toString() {
    return 'ShipperCompanyModel(id: $id, firstName: $firstName, lastName: $lastName, companyName: $companyName, businessName: $businessName, companyEmail: $companyEmail, address: $address)';
  }
}
