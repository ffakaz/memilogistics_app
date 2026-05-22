// lib/features/shipment/domain/entities/carrier_profile.dart

import 'package:memilogistics_app/features/carrier/domain/entities/address.dart';
import 'shipment_offer.dart';

/// Carrier profile entity (simplified version for shipment context)
class CarrierProfile {
  final int id;
  final String managerUserId;
  final String companyName;
  final Address address;
  final String authenticationEmail;
  final String companyEmail;
  final List<String> assignedShipments;
  final List<ShipmentOffer> offeredShipments;

  const CarrierProfile({
    required this.id,
    required this.managerUserId,
    required this.companyName,
    required this.address,
    required this.authenticationEmail,
    required this.companyEmail,
    required this.assignedShipments,
    required this.offeredShipments,
  });

  CarrierProfile copyWith({
    int? id,
    String? managerUserId,
    String? companyName,
    Address? address,
    String? authenticationEmail,
    String? companyEmail,
    List<String>? assignedShipments,
    List<ShipmentOffer>? offeredShipments,
  }) {
    return CarrierProfile(
      id: id ?? this.id,
      managerUserId: managerUserId ?? this.managerUserId,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      authenticationEmail: authenticationEmail ?? this.authenticationEmail,
      companyEmail: companyEmail ?? this.companyEmail,
      assignedShipments: assignedShipments ?? this.assignedShipments,
      offeredShipments: offeredShipments ?? this.offeredShipments,
    );
  }
}
