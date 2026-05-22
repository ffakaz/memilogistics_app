import '../enums/safety_option.dart';
import '../enums/shipment_status.dart';
import '../enums/shipment_type.dart';
import '../enums/weight_unit.dart';

import 'location.dart';
import 'delivery_confirmation.dart';
import 'payment_record.dart';
import 'shipper_profile.dart';
import 'carrier_profile.dart';
import 'shipment_offer.dart';
import 'shipment_event.dart';

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

  // New backend fields (from updated API response)
  final String? shipmentItem;
  final double? weightKg;
  final String? origin; // String location instead of Location object
  final String? destination; // String location instead of Location object
  final DateTime? estimatedDeliveryDate;
  final bool? fragile;

  // Enhanced objects
  final DeliveryConfirmation? deliveryConfirmation;
  final PaymentRecord? paymentRecord;
  final ShipperProfile? shipper;
  final CarrierProfile? assignedCarrier;
  final List<ShipmentOffer>? shipmentOffers;
  final List<ShipmentEvent>? shipmentEvents;

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
    this.shipmentItem,
    this.weightKg,
    this.origin,
    this.destination,
    this.estimatedDeliveryDate,
    this.fragile,
    this.deliveryConfirmation,
    this.paymentRecord,
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
    String? shipmentItem,
    double? weightKg,
    String? origin,
    String? destination,
    DateTime? estimatedDeliveryDate,
    bool? fragile,
    DeliveryConfirmation? deliveryConfirmation,
    PaymentRecord? paymentRecord,
    ShipperProfile? shipper,
    CarrierProfile? assignedCarrier,
    List<ShipmentOffer>? shipmentOffers,
    List<ShipmentEvent>? shipmentEvents,
  }) {
    return Shipment(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      shipperName: shipperName ?? this.shipperName,
      shipmentType: shipmentType ?? this.shipmentType,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      pickupDate: pickupDate ?? this.pickupDate,
      safetyOption: safetyOption ?? this.safetyOption,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      volume: volume ?? this.volume,
      shipmentItem: shipmentItem ?? this.shipmentItem,
      weightKg: weightKg ?? this.weightKg,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      fragile: fragile ?? this.fragile,
      deliveryConfirmation: deliveryConfirmation ?? this.deliveryConfirmation,
      paymentRecord: paymentRecord ?? this.paymentRecord,
      shipper: shipper ?? this.shipper,
      assignedCarrier: assignedCarrier ?? this.assignedCarrier,
      shipmentOffers: shipmentOffers ?? this.shipmentOffers,
      shipmentEvents: shipmentEvents ?? this.shipmentEvents,
    );
  }

  // Compatibility getters expected by some UI code
  // Note: origin and destination fields are strings from backend
  // These getters provide Location objects for backward compatibility
  Location get originAsLocation => pickupLocation;
  Location get destinationAsLocation => destinationLocation;
  double get weight => amount;
  WeightUnit get weightUnit => unit;

  int get offerCount => shipmentOffers?.length ?? 0;
}
