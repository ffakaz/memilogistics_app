import '../enums/shipment_status.dart';
import '../enums/safety_option.dart';
import '../enums/shipment_type.dart';
import '../enums/weight_unit.dart';
import 'location.dart';

class Shipment {
  final int? id;
  final String? trackingNumber;
  final String origin;
  final String destination;
  final double weightKg;
  final double? volume;
  final ShipmentStatus status;
  final DateTime? pickupDate;
  final DateTime? estimatedDeliveryDate;
  final String? shipmentItem;
  final String? description;
  final bool fragile;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final int? shipperId;
  final int? assignedCarrierId;

  // Legacy fields for backward compatibility (will be removed)
  @Deprecated('Use origin string instead')
  final Location? pickupLocation;
  @Deprecated('Use destination string instead')
  final Location? destinationLocation;
  @Deprecated('Use weightKg instead')
  final double? amount;
  @Deprecated('Use weightKg instead')
  final WeightUnit? unit;
  @Deprecated('Use fragile instead')
  final SafetyOption? safetyOption;
  @Deprecated('Use shipmentItem instead')
  final ShipmentType? shipmentType;
  @Deprecated('Not used')
  final String? shipperName;

  const Shipment({
    this.id,
    this.trackingNumber,
    required this.origin,
    required this.destination,
    required this.weightKg,
    this.volume,
    required this.status,
    this.pickupDate,
    this.estimatedDeliveryDate,
    this.shipmentItem,
    this.description,
    required this.fragile,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.shipperId,
    this.assignedCarrierId,
    // Legacy fields
    this.pickupLocation,
    this.destinationLocation,
    this.amount,
    this.unit,
    this.safetyOption,
    this.shipmentType,
    this.shipperName,
  });

  Shipment copyWith({
    int? id,
    String? trackingNumber,
    String? origin,
    String? destination,
    double? weightKg,
    double? volume,
    ShipmentStatus? status,
    DateTime? pickupDate,
    DateTime? estimatedDeliveryDate,
    String? shipmentItem,
    String? description,
    bool? fragile,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? shipperId,
    int? assignedCarrierId,
  }) {
    return Shipment(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      weightKg: weightKg ?? this.weightKg,
      volume: volume ?? this.volume,
      status: status ?? this.status,
      pickupDate: pickupDate ?? this.pickupDate,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      shipmentItem: shipmentItem ?? this.shipmentItem,
      description: description ?? this.description,
      fragile: fragile ?? this.fragile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      shipperId: shipperId ?? this.shipperId,
      assignedCarrierId: assignedCarrierId ?? this.assignedCarrierId,
    );
  }

  // Getter for offer count (will be 0 until we implement offers loading)
  int get offerCount => 0; // placeholder until offers are loaded separately

  // Convenience getters for backward compatibility with UI code
  Location get originAsLocation => pickupLocation ?? Location(address: origin);
  Location get destinationAsLocation => destinationLocation ?? Location(address: destination);
  double get weight => weightKg;
  String get weightUnit => 'kg';
}