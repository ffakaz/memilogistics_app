import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_information.dart';
import '../../domain/entities/shipment.dart';
import 'package:memilogistics_app/features/shipment_offer/data/models/shipment_offer_model.dart';
import '../../domain/enums/shipment_status.dart';
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
  List<Shipment> _assignedShipments = [];
  final Map<int, List<ShipmentOfferModel>> _offersCache = {};
  final Set<int> _submittingOffers = {};
  Shipment? _activeShipment;
  DashboardInformation _dashboardInformation = DashboardInformation.empty;
  bool _isDashboardLoading = false;

  // Pagination state
  int _currentPage = 0;
  int _pageSize = 20;
  int _totalPages = 0;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  // Statistics state (Phase 3)
  dynamic _statistics;
  bool _isLoadingStatistics = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Shipment> get shipments => _shipments;
  List<Shipment> get assignedShipments => _assignedShipments;
  Map<int, List<ShipmentOfferModel>> get offersCache => _offersCache;
  bool isSubmittingOffer(int shipmentId) => _submittingOffers.contains(shipmentId);
  Shipment? get activeShipment => _activeShipment;
  DashboardInformation get dashboardInformation => _dashboardInformation;
  bool get isDashboardLoading => _isDashboardLoading;
  
  // Pagination getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMorePages => _hasMorePages;
  bool get isLoadingMore => _isLoadingMore;

  // Statistics getters
  dynamic get statistics => _statistics;
  bool get isLoadingStatistics => _isLoadingStatistics;

  Future<void> createShipment({
    required int shipperId,  // Required: Shipper ID from shipper profile
    required String shipmentItem,
    required double weightKg,
    required String origin,
    required String destination,
    required DateTime pickupDate,
    required bool fragile,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final shipment = Shipment(
        origin: origin,
        destination: destination,
        weightKg: weightKg,
        fragile: fragile,
        status: ShipmentStatus.pending,
        pickupDate: pickupDate,
        shipmentItem: shipmentItem,
        description: description,
      );

      final createdShipment = await repository.createShipment(
        shipment,
        shipperId: shipperId,
      );

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

  // Helper methods removed - no longer needed

  Future<void> getAvailableShipments() async {
    _setLoading(true);
    _clearError();

    try {
      print('📦 Fetching available shipments...');
      
      // Get shipments from backend
      _shipments = await repository.listShipments(page: 0, size: 50);

      print('📦 Received ${_shipments.length} shipments from backend');
      
      // Log shipment statuses for debugging
      final statusCounts = <ShipmentStatus, int>{};
      for (final shipment in _shipments) {
        statusCounts[shipment.status] = (statusCounts[shipment.status] ?? 0) + 1;
      }
      print('📦 Shipment status breakdown:');
      statusCounts.forEach((status, count) {
        print('   ${status.displayName}: $count');
      });

      // Filter to only show pending shipments (available for bidding)
      final pendingShipments = _shipments
          .where((s) => s.status == ShipmentStatus.pending)
          .toList();
      
      print('📦 Filtered to ${pendingShipments.length} PENDING shipments available for offers');
      
      _shipments = pendingShipments;

      notifyListeners();
    } catch (e) {
      print('❌ Failed to load available shipments: $e');
      _setError('Failed to load shipments: ${e.toString()}');
      _shipments = []; // Empty list on error - no mock data
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch shipments assigned to a specific carrier by id
  Future<List<Shipment>> getAssignedShipmentsByCarrierId(int carrierId) async {
    try {
      final models = await repository.getCarrierAssignedShipmentsById(carrierId);
      return models;
    } catch (e) {
      _setError('Failed to load assigned shipments: ${e.toString()}');
      return [];
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
    if (_submittingOffers.contains(shipmentId)) return;
    _submittingOffers.add(shipmentId);
    _clearError();

    // Optimistic update: add a temporary offer to the cache
    final tempOffer = ShipmentOfferModel(
      id: DateTime.now().millisecondsSinceEpoch * -1,
      createdAt: DateTime.now().toUtc(),
      price: price,
      shipmentId: shipmentId,
      shipmentTrackingNumber: _activeShipment?.trackingNumber ?? '',
      carrierCompanyId: null,
      carrierCompany: null,
    );

    _offersCache.putIfAbsent(shipmentId, () => []);
    _offersCache[shipmentId] = [tempOffer, ..._offersCache[shipmentId]!];
    notifyListeners();

    try {
      await repository.offerShipment(shipmentId: shipmentId, price: price);

      // On success, refresh offers from backend to reconcile
      final fresh = await repository.getShipmentOffers(shipmentId);
      _offersCache[shipmentId] = fresh;
      notifyListeners();
    } catch (e) {
      // Rollback optimistic update
      _offersCache[shipmentId]?.removeWhere((o) => o.id == tempOffer.id);
      _setError('Failed to submit offer: ${e.toString()}');
      notifyListeners();
      rethrow;
    } finally {
      _submittingOffers.remove(shipmentId);
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
            _activeShipment?.destination ?? 'Unknown',
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
  // Get my shipments (role-aware)
  // Note: Backend automatically filters shipments by authenticated user via JWT token.
  // Shippers see only their shipments, carriers see assigned shipments.
  Future<void> getMyShipments({String? role}) async {
    _setLoading(true);
    _clearError();

    try {
      print('📦 Fetching my shipments (role-aware) using /shipment/my endpoint...');
      
      // Use the paginated endpoint that calls /api/shipment/my
      final paginatedResponse = await repository.getShipperShipmentsPaginated(
        page: 0,
        size: 50,
      );
      
      _shipments = paginatedResponse.shipments;
      _currentPage = paginatedResponse.currentPage;
      _totalPages = paginatedResponse.totalPages;
      _hasMorePages = paginatedResponse.hasMore;

      print('📦 Received ${_shipments.length} shipments from backend');

      notifyListeners();
    } catch (e) {
      print('❌ Failed to load my shipments: $e');
      _setError('Failed to load shipments: ${e.toString()}');
      _shipments = []; // Empty list on error - no mock data
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load shipments with pagination (new method for Phase 1)
  Future<void> loadShipmentsPaginated({int page = 0, int size = 20, bool append = false}) async {
    // Prevent multiple simultaneous loads
    if (_isLoadingMore && append) return;
    
    if (append) {
      _isLoadingMore = true;
    } else {
      _setLoading(true);
    }
    _clearError();

    try {
      final paginatedResponse = await repository.listShipmentsPaginated(
        page: page,
        size: size,
      );

      if (append) {
        // Append to existing list
        _shipments.addAll(paginatedResponse.shipments);
      } else {
        // Replace list
        _shipments = paginatedResponse.shipments;
      }

      _currentPage = paginatedResponse.currentPage;
      _totalPages = paginatedResponse.totalPages;
      _hasMorePages = paginatedResponse.hasMore;
      _pageSize = size;

      notifyListeners();
    } catch (e) {
      _setError('Failed to load shipments: ${e.toString()}');
      if (!append) {
        _shipments = []; // Empty list on error only if not appending
      }
      notifyListeners();
    } finally {
      if (append) {
        _isLoadingMore = false;
      } else {
        _setLoading(false);
      }
      notifyListeners();
    }
  }

  // Load next page (for infinite scroll)
  Future<void> loadNextPage() async {
    if (!_hasMorePages || _isLoadingMore || _isLoading) return;
    await loadShipmentsPaginated(
      page: _currentPage + 1,
      size: _pageSize,
      append: true,
    );
  }

  // Refresh shipments (pull-to-refresh)
  Future<void> refreshShipments() async {
    await loadShipmentsPaginated(page: 0, size: _pageSize, append: false);
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

  // Get shipment offers (Phase 2)
  Future<List<dynamic>> loadShipmentOffers(int shipmentId) async {
    try {
      return await repository.getShipmentOffers(shipmentId);
    } catch (e) {
      _setError('Failed to load shipment offers: ${e.toString()}');
      rethrow;
    }
  }

  /// Fetch offers and populate local cache
  Future<void> fetchShipmentOffers(int shipmentId) async {
    _clearError();
    try {
      final offers = await repository.getShipmentOffers(shipmentId);
      _offersCache[shipmentId] = offers;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load shipment offers: ${e.toString()}');
      rethrow;
    }
  }

  /// Cancel an offer with optimistic removal
  Future<void> cancelShipmentOffer({required int shipmentId, required int shipmentOfferId}) async {
    _clearError();

    final existing = _offersCache[shipmentId] ?? [];
    final removed = existing.where((o) => o.id == shipmentOfferId).toList();
    if (removed.isEmpty) return;

    // Optimistic removal
    _offersCache[shipmentId] = existing.where((o) => o.id != shipmentOfferId).toList();
    notifyListeners();

    try {
      await repository.cancelShipmentOffer(shipmentOfferId);
    } catch (e) {
      // rollback
      _offersCache[shipmentId] = [..._offersCache[shipmentId] ?? [], ...removed];
      _setError('Failed to cancel offer: ${e.toString()}');
      notifyListeners();
      rethrow;
    }
  }

  // Load shipment statistics (Phase 3)
  Future<void> loadStatistics() async {
    _isLoadingStatistics = true;
    _clearError();
    notifyListeners();

    try {
      _statistics = await repository.getShipmentStatistics();
      _isLoadingStatistics = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load statistics: ${e.toString()}');
      _isLoadingStatistics = false;
      notifyListeners();
    }
  }

  // Get carrier's assigned shipments
  Future<void> getCarrierAssignedShipments() async {
    _setLoading(true);
    _clearError();

    try {
      _assignedShipments = await repository.getCarrierAssignedShipments();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load assigned shipments: ${e.toString()}');
      _assignedShipments = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Get specific carrier's assigned shipments (for admin/manager)
  Future<void> getCarrierAssignedShipmentsById(int carrierId) async {
    _setLoading(true);
    _clearError();

    try {
      _assignedShipments = await repository.getCarrierAssignedShipmentsById(carrierId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load carrier assigned shipments: ${e.toString()}');
      _assignedShipments = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
}
