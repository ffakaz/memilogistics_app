import '../enums/safety_option.dart';
import '../enums/shipment_status.dart';
import '../enums/shipment_type.dart';
import '../enums/weight_unit.dart';
import 'location.dart';

class Shipment {
  final String? id; // Backend assigns this
  final String shipperName;
  final ShipmentType shipmentType;
  final double amount;
  final WeightUnit unit;
  final Location pickupLocation;
  final Location destinationLocation;
  final DateTime pickupDate;
  final SafetyOption safetyOption;
  final ShipmentStatus status;
  final String? description;
  final DateTime? createdAt;

  Shipment({
    this.id, // Optional - backend assigns
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
  });

  // Convenience getters for load board display
  double get weight => amount;
  WeightUnit get weightUnit => unit;
  Location get origin => pickupLocation;
  Location get destination => destinationLocation;
}
