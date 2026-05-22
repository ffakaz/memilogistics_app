// lib/features/shipment/domain/entities/shipper_profile.dart

import 'package:memilogistics_app/features/carrier/domain/entities/address.dart';

/// Shipper profile entity (simplified version for shipment context)
class ShipperProfile {
  final int id;
  final String authenticationEmail;
  final String firstName;
  final String lastName;
  final String companyName;
  final String businessName;
  final Address address;
  final List<String> shipments;

  const ShipperProfile({
    required this.id,
    required this.authenticationEmail,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.businessName,
    required this.address,
    required this.shipments,
  });

  String get fullName => '$firstName $lastName';

  ShipperProfile copyWith({
    int? id,
    String? authenticationEmail,
    String? firstName,
    String? lastName,
    String? companyName,
    String? businessName,
    Address? address,
    List<String>? shipments,
  }) {
    return ShipperProfile(
      id: id ?? this.id,
      authenticationEmail: authenticationEmail ?? this.authenticationEmail,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      shipments: shipments ?? this.shipments,
    );
  }
}
