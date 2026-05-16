import 'package:flutter/material.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/safety_option.dart';
import '../../domain/enums/shipment_status.dart';
import '../../domain/enums/shipment_type.dart';
import '../../domain/enums/weight_unit.dart';
import '../../domain/repositories/shipment_repository.dart';

class ShipmentProvider extends ChangeNotifier {
  final ShipmentRepository repository;

  ShipmentProvider({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;
  List<Shipment> _shipments = [];
  Shipment? _activeShipment;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Shipment> get shipments => _shipments;
  Shipment? get activeShipment => _activeShipment;

  Future<void> createShipment({
    required String shipperName,
    required ShipmentType shipmentType,
    required double amount,
    required WeightUnit unit,
    required String pickup,
    required String destination,
    required DateTime pickupDate,
    required SafetyOption safetyOption,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final shipment = Shipment(
        shipperName: shipperName,
        shipmentType: shipmentType,
        amount: amount,
        unit: unit,
        pickupLocation: Location(address: pickup),
        destinationLocation: Location(address: destination),
        pickupDate: pickupDate,
        safetyOption: safetyOption,
        status: ShipmentStatus.pending, // Backend will manage status transitions based on events
      );

      await repository.createShipment(shipment);
    } catch (e) {
      _setError('Failed to create shipment: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getAvailableShipments() async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement repository method to get available shipments
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));

      _shipments = _getMockShipments();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load shipments: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  List<Shipment> _getMockShipments() {
    return [
      Shipment(
        id: 'SHP001',
        shipperName: 'ABC Manufacturing',
        shipmentType: ShipmentType.dryGoods,
        amount: 6800,
        unit: WeightUnit.kg,
        pickupLocation: const Location(
          address: '123 Industrial Pkwy',
          city: 'Chicago',
          state: 'IL',
          zipCode: '60601',
          country: 'USA',
        ),
        destinationLocation: const Location(
          address: '456 Commerce St',
          city: 'Dallas',
          state: 'TX',
          zipCode: '75201',
          country: 'USA',
        ),
        pickupDate: DateTime.now().add(const Duration(days: 2)),
        safetyOption: SafetyOption.normal,
        status: ShipmentStatus.pending,
        description: 'Industrial equipment - requires flatbed',
      ),
      Shipment(
        id: 'SHP002',
        shipperName: 'XYZ Logistics',
        shipmentType: ShipmentType.electronics,
        amount: 2300,
        unit: WeightUnit.kg,
        pickupLocation: const Location(
          address: '789 Warehouse Rd',
          city: 'Los Angeles',
          state: 'CA',
          zipCode: '90001',
          country: 'USA',
        ),
        destinationLocation: const Location(
          address: '321 Distribution Ave',
          city: 'Phoenix',
          state: 'AZ',
          zipCode: '85001',
          country: 'USA',
        ),
        pickupDate: DateTime.now().add(const Duration(days: 1)),
        safetyOption: SafetyOption.fragile,
        status: ShipmentStatus.pending,
        description: 'Electronics - fragile, handle with care',
      ),
      Shipment(
        id: 'SHP003',
        shipperName: 'Global Trade Co',
        shipmentType: ShipmentType.dryGoods,
        amount: 9,
        unit: WeightUnit.ton,
        pickupLocation: const Location(
          address: '555 Port Blvd',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
        ),
        destinationLocation: const Location(
          address: '888 Market St',
          city: 'Boston',
          state: 'MA',
          zipCode: '02101',
          country: 'USA',
        ),
        pickupDate: DateTime.now().add(const Duration(days: 3)),
        safetyOption: SafetyOption.normal,
        status: ShipmentStatus.pending,
        description: 'Consumer goods - standard delivery',
      ),
    ];
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Set active shipment for detail view
  void setActiveShipment(Shipment? shipment) {
    _activeShipment = shipment;
    notifyListeners();
  }

  // Get shipment by ID
  Shipment? getShipmentById(String id) {
    try {
      return _shipments.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Accept shipment (carrier action)
  Future<void> acceptShipment(String shipmentId) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Call accept shipment use case
      // For now, update status locally
      final index = _shipments.indexWhere((s) => s.id == shipmentId);
      if (index != -1) {
        final updatedShipment = Shipment(
          id: _shipments[index].id,
          shipperName: _shipments[index].shipperName,
          shipmentType: _shipments[index].shipmentType,
          amount: _shipments[index].amount,
          unit: _shipments[index].unit,
          pickupLocation: _shipments[index].pickupLocation,
          destinationLocation: _shipments[index].destinationLocation,
          pickupDate: _shipments[index].pickupDate,
          safetyOption: _shipments[index].safetyOption,
          status: ShipmentStatus.assigned, // POSTED → ACCEPTED
          description: _shipments[index].description,
          createdAt: _shipments[index].createdAt,
        );
        _shipments[index] = updatedShipment;
        if (_activeShipment?.id == shipmentId) {
          _activeShipment = updatedShipment;
        }
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to accept shipment: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update shipment status (carrier action)
  Future<void> updateShipmentStatus(String shipmentId, ShipmentStatus newStatus) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Call update status use case with validation
      final index = _shipments.indexWhere((s) => s.id == shipmentId);
      if (index != -1) {
        final updatedShipment = Shipment(
          id: _shipments[index].id,
          shipperName: _shipments[index].shipperName,
          shipmentType: _shipments[index].shipmentType,
          amount: _shipments[index].amount,
          unit: _shipments[index].unit,
          pickupLocation: _shipments[index].pickupLocation,
          destinationLocation: _shipments[index].destinationLocation,
          pickupDate: _shipments[index].pickupDate,
          safetyOption: _shipments[index].safetyOption,
          status: newStatus,
          description: _shipments[index].description,
          createdAt: _shipments[index].createdAt,
        );
        _shipments[index] = updatedShipment;
        if (_activeShipment?.id == shipmentId) {
          _activeShipment = updatedShipment;
        }
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update shipment status: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get my shipments (role-aware)
  Future<void> getMyShipments({String? role}) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement role-based filtering with use case
      // For now, return all shipments
      await Future.delayed(const Duration(seconds: 1));
      _shipments = _getMockShipments();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load shipments: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
