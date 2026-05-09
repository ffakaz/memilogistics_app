import '../enums/safety_option.dart';
import '../enums/shipment_type.dart';
import '../enums/weight_unit.dart';
import 'location.dart';

class Shipment {
  final String shipperName;
  final ShipmentType shipmentType;
  final double amount;
  final WeightUnit unit;
  final Location pickupLocation;
  final Location destinationLocation;
  final DateTime pickupDate;
  final SafetyOption safetyOption;

  Shipment({
    required this.shipperName,
    required this.shipmentType,
    required this.amount,
    required this.unit,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupDate,
    required this.safetyOption,
  });
}