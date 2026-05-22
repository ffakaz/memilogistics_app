// lib/features/shipper/domain/entities/shipper_company.dart

import '../../../carrier/domain/entities/address.dart';

/// Shipper Company Entity
///
/// Represents a shipper company profile in the domain layer.
/// This is the business entity used throughout the application.
class ShipperCompany {
  final int id;
  final String firstName;
  final String lastName;
  final String companyName;
  final String businessName;
  final String companyEmail;
  final Address address;

  const ShipperCompany({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.businessName,
    required this.companyEmail,
    required this.address,
  });

  String get fullName {
    final value = '$firstName $lastName'.trim();
    return value.isEmpty ? companyName : value;
  }

  /// Creates a copy of this entity with the given fields replaced
  ShipperCompany copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? companyName,
    String? businessName,
    String? companyEmail,
    Address? address,
  }) {
    return ShipperCompany(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      businessName: businessName ?? this.businessName,
      companyEmail: companyEmail ?? this.companyEmail,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'ShipperCompany(id: $id, firstName: $firstName, lastName: $lastName, companyName: $companyName, businessName: $businessName, companyEmail: $companyEmail, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShipperCompany &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.companyName == companyName &&
        other.businessName == businessName &&
        other.companyEmail == companyEmail &&
        other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        companyName.hashCode ^
        businessName.hashCode ^
        companyEmail.hashCode ^
        address.hashCode;
  }
}
