import 'package:flutter/material.dart';
import '../../domain/repositories/shipment_repository.dart';

class ShipmentProvider extends ChangeNotifier {
  final ShipmentRepository repository;

  ShipmentProvider({
    required this.repository,
  });

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> createShipment({
    required String shipperName,
    required String shipmentType,
    required double amount,
    required String unit,
    required String pickup,
    required String destination,
    required DateTime pickupDate,
    required String safetyOption,
  }) async {
    _setLoading(true);

    try {
      final shipment = {
        'shipperName': shipperName,
        'shipmentType': shipmentType,
        'amount': amount,
        'unit': unit,
        'pickupPoint': pickup,
        'destination': destination,
        'pickupDate': pickupDate.toIso8601String(),
        'safetyOption': safetyOption.toUpperCase(),
      };

      await repository.createShipment(shipment);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}