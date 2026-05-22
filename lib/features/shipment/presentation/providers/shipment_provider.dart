import 'package:flutter/material.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/dashboard_information.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/safety_option.dart';
import '../../domain/enums/shipment_status.dart';
import '../../domain/enums/shipment_type.dart';
import '../../domain/enums/weight_unit.dart';
import '../../domain/repositories/shipment_repository.dart';
import '../../domain/usecases/get_dashboard_information.dart';

class ShipmentProvider extends ChangeNotifier {
  final ShipmentRepository repository;
  final GetDashboardInformation getDashboardInformationUseCase;

  ShipmentProvider({
    required this.repository,
    required this.getDashboardInformationUseCase,
  });

  bool _isLoading = false;
  String? _errorMessage;
  List<Shipment> _shipments = [];
  Shipment? _activeShipment;
  DashboardInformation _dashboardInformation = DashboardInformation.empty;
  bool _isDashboardLoading = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Shipment> get shipments => _shipments;
  Shipment? get activeShipment => _activeShipment;
  DashboardInformation get dashboardInformation => _dashboardInformation;
  bool get isDashboardLoading => _isDashboardLoading;

  Future<void> createShipment({
    required String shipperName,
    required ShipmentType shipmentType,
    required double amount,
    required WeightUnit unit,
    required String pickup,
    required String destination,
    required DateTime pickupDate,
    required SafetyOption safetyOption,
    String? description,
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
        status: ShipmentStatus
            .pending, // Backend will manage status transitions based on events
        description: description,
      );

      final createdShipment = await repository.createShipment(shipment);

      // Add to local list
      _shipments.add(createdShipment);
      notifyListeners();
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
      // Get shipments from backend
      _shipments = await repository.listShipments(page: 0, size: 50);

      // Filter to only show pending shipments (available for bidding)
      _shipments = _shipments
          .where((s) => s.status == ShipmentStatus.pending)
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load shipments: ${e.toString()}');
      _shipments = []; // Empty list on error - no mock data
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getDashboardInformation() async {
    _isDashboardLoading = true;
    _clearError();
    notifyListeners();

    try {
      _dashboardInformation = await getDashboardInformationUseCase();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load dashboard information: ${e.toString()}');
      _dashboardInformation = DashboardInformation.empty;
      notifyListeners();
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
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
  Shipment? getShipmentById(int id) {
    try {
      return _shipments.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Accept shipment (carrier action)
  // Note: Shipment assignment happens via offer acceptance flow in the current implementation.
  // This method provides an alternative direct assignment flow (not currently used).
  // The standard flow is: Carrier submits offer → Shipper accepts → Backend assigns carrier
  Future<void> acceptShipment(int shipmentId) async {
    _setLoading(true);
    _clearError();

    try {
      // Alternative flow: Direct assignment without offer
      // For now, update status locally
      final index = _shipments.indexWhere((s) => s.id == shipmentId);
      if (index != -1) {
        final updatedShipment = _shipments[index].copyWith(
          status: ShipmentStatus.assigned,
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

  Future<void> submitShipmentOffer({
    required int shipmentId,
    required double price,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await repository.offerShipment(shipmentId: shipmentId, price: price);
    } catch (e) {
      _setError('Failed to submit offer: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> assignCarrier({
    required int shipmentId,
    required int carrierId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await repository.assignCarrier(
        shipmentId: shipmentId,
        carrierId: carrierId,
      );
      await getMyShipments();
    } catch (e) {
      _setError('Failed to assign carrier: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update shipment status (carrier action)
  Future<void> updateShipmentStatus(
    int shipmentId,
    ShipmentStatus newStatus,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedShipment = await repository.updateShipmentStatus(
        shipmentId: shipmentId,
        status: newStatus,
        location:
            _activeShipment?.destinationAsLocation.shortLabel ?? 'Unknown',
      );
      final index = _shipments.indexWhere((s) => s.id == shipmentId);
      if (index != -1) {
        _shipments[index] = updatedShipment;
      }
      if (_activeShipment?.id == shipmentId) {
        _activeShipment = updatedShipment;
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to update shipment status: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get my shipments (role-aware)
  // Note: Backend automatically filters shipments by authenticated user via JWT token.
  // Shippers see only their shipments, carriers see assigned shipments.
  Future<void> getMyShipments({String? role}) async {
    _setLoading(true);
    _clearError();

    try {
      // Get all shipments from backend (already filtered by user)
      _shipments = await repository.listShipments(page: 0, size: 50);

      notifyListeners();
    } catch (e) {
      _setError('Failed to load shipments: ${e.toString()}');
      _shipments = []; // Empty list on error - no mock data
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Get shipment events
  Future<List<Map<String, dynamic>>> getShipmentEvents(int shipmentId) async {
    try {
      return await repository.getShipmentEvents(shipmentId);
    } catch (e) {
      _setError('Failed to load shipment events: ${e.toString()}');
      rethrow;
    }
  }
}
