import 'location_model.dart';

class ShipmentModel {
  final String shipperName;
  final String shipmentType;
  final double amount;
  final String unit;
  final LocationModel pickupLocation;
  final LocationModel destinationLocation;
  final DateTime pickupDate;
  final String safetyOption;
  final String status;

  const ShipmentModel({
    required this.shipperName,
    required this.shipmentType,
    required this.amount,
    required this.unit,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupDate,
    required this.safetyOption,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'shipperName': shipperName,
      'shipmentType': shipmentType,
      'amount': amount,
      'unit': unit,
      'pickupLocation': pickupLocation.toJson(),
      'destinationLocation': destinationLocation.toJson(),
      'pickupDate': pickupDate.toIso8601String(),
      'safetyOption': safetyOption,
      'status': status,
    };
  }
}
