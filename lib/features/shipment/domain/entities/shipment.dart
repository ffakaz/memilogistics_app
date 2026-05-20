import '../enums/safety_option.dart';
import '../enums/shipment_status.dart';
import '../enums/shipment_type.dart';
import '../enums/weight_unit.dart';

import 'location.dart';

class Shipment {
  final int? id;
  final String? trackingNumber;

  final String shipperName;

  final ShipmentType shipmentType;

  final double amount;

  final WeightUnit unit;

  final Location pickupLocation;

  final Location destinationLocation;

  final DateTime pickupDate;

  final SafetyOption safetyOption;

  final ShipmentStatus status;

  // Optional backend fields
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final double? volume;
  final Map<String, dynamic>? shipper;
  final dynamic assignedCarrier;
  final List<dynamic>? shipmentOffers;
  final List<dynamic>? shipmentEvents;

  const Shipment({
    this.id,
    this.trackingNumber,
    required this.shipperName,
    required this.shipmentType,
    required this.amount,
    required this.unit,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupDate,
    required this.safetyOption,
    required this.status,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.volume,
    this.shipper,
    this.assignedCarrier,
    this.shipmentOffers,
    this.shipmentEvents,
  });

  Shipment copyWith({
    int? id,
    String? trackingNumber,
    String? shipperName,
    ShipmentType? shipmentType,
    double? amount,
    WeightUnit? unit,
    Location? pickupLocation,
    Location? destinationLocation,
    DateTime? pickupDate,
    SafetyOption? safetyOption,
    ShipmentStatus? status,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    double? volume,
    Map<String, dynamic>? shipper,
    dynamic assignedCarrier,
    List<dynamic>? shipmentOffers,
    List<dynamic>? shipmentEvents,
  }) {
    return Shipment(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      shipperName: shipperName ?? this.shipperName,
      shipmentType: shipmentType ?? this.shipmentType,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      pickupLocation:
          pickupLocation ?? this.pickupLocation,
      destinationLocation:
          destinationLocation ??
              this.destinationLocation,
      pickupDate: pickupDate ?? this.pickupDate,
      safetyOption:
          safetyOption ?? this.safetyOption,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      volume: volume ?? this.volume,
      shipper: shipper ?? this.shipper,
      assignedCarrier: assignedCarrier ?? this.assignedCarrier,
      shipmentOffers: shipmentOffers ?? this.shipmentOffers,
      shipmentEvents: shipmentEvents ?? this.shipmentEvents,
    );
  }

  // Compatibility getters expected by some UI code
  Location get origin => pickupLocation;
  Location get destination => destinationLocation;
  double get weight => amount;
  WeightUnit get weightUnit => unit;

  int get offerCount => shipmentOffers?.length ?? 0;
}