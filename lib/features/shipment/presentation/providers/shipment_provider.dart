import 'dart:async';
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
  final Set<int> _mutatingOfferIds = {};
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
  bool isSubmittingOffer(int shipmentId) =>
      _submittingOffers.contains(shipmentId);
  bool isMutatingOffer(int shipmentOfferId) =>
      _mutatingOfferIds.contains(shipmentOfferId);
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

  Future<List<Shipment>> getMyShipmentsByStatus({
    required ShipmentStatus status,
    int page = 0,
    int size = 20,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final shipments = await repository.getMyShipmentsByStatus(
        status: status,
        page: page,
        size: size,
      );
      for (final shipment in shipments) {
        _upsertShipment(shipment);
      }
      notifyListeners();
      return shipments;
    } catch (e) {
      _setError('Failed to load ${status.displayName} shipments: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<ShipmentStatus, List<Shipment>>> getMyShipmentStatusBuckets(
    List<ShipmentStatus> statuses, {
    int page = 0,
    int size = 20,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final buckets = <ShipmentStatus, List<Shipment>>{};
      for (final status in statuses) {
        final shipments = await repository.getMyShipmentsByStatus(
          status: status,
          page: page,
          size: size,
        );
        buckets[status] = shipments;
        for (final shipment in shipments) {
          _upsertShipment(shipment);
        }
      }
      notifyListeners();
      return buckets;
    } catch (e) {
      _setError('Failed to load shipments by status: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createShipment({
    required int shipperId, // Required: Shipper ID from shipper profile
    required String shipmentItem,
    required double weightKg,
    required String origin,
    required String destination,
    required DateTime pickupDate,
    required bool fragile,
    String? description,
    String? idempotencyKey,
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
        idempotencyKey: idempotencyKey,
      );

      // Add to local list using upsert to avoid duplicates and keep latest data
      if (createdShipment.id != null) {
        final existingIndex = _shipments.indexWhere((s) => s.id == createdShipment.id);
        if (existingIndex == -1) {
          _shipments.add(createdShipment);
        } else {
          _shipments[existingIndex] = createdShipment;
        }
      } else {
        // Fallback: append if no id provided
        _shipments.add(createdShipment);
      }
      // Deduplicate by id to guard against backend or pagination duplicates
      _dedupeShipmentsById();
      notifyListeners();
      // Trigger background refresh of related lists to synchronize UI across tabs
      unawaited(getCarrierAssignedShipments());
      unawaited(getMyShipments());
      unawaited(getDashboardInformation());
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

      // The carrier load board must not use /shipment/my/status because that
      // endpoint is scoped to the authenticated user's own shipments.
      final allShipments = await repository.listShipments(
        page: 0,
        size: 50,
      );

      print('📦 Received ${allShipments.length} shipments from backend');

      // Log shipment statuses for debugging
      final statusCounts = <ShipmentStatus, int>{};
      for (final shipment in allShipments) {
        statusCounts[shipment.status] =
            (statusCounts[shipment.status] ?? 0) + 1;
      }
      print('📦 Shipment status breakdown:');
      statusCounts.forEach((status, count) {
        print('   ${status.displayName}: $count');
      });

      // CRITICAL: Deduplicate shipments by ID to prevent duplicate offers
      // Backend might return duplicates due to database joins or pagination issues
      final uniqueShipmentsMap = <int, Shipment>{};
      final shipmentsWithoutId = <Shipment>[];
      
      for (final shipment in allShipments) {
        if (shipment.id != null) {
          // Only keep the first occurrence of each shipment ID
          if (!uniqueShipmentsMap.containsKey(shipment.id!)) {
            uniqueShipmentsMap[shipment.id!] = shipment;
          } else {
            print('⚠️ Duplicate shipment detected and removed: ID=${shipment.id}');
          }
        } else {
          // Shipments without IDs (should not happen, but handle gracefully)
          shipmentsWithoutId.add(shipment);
        }
      }

      final deduplicatedShipments = [
        ...uniqueShipmentsMap.values,
        ...shipmentsWithoutId,
      ];

      print('📦 After deduplication: ${deduplicatedShipments.length} unique shipments');

        // Filter to show unassigned shipments that are available for offers
        // Business rule: Show shipments where assignedCarrierId == null
        // Status can be PENDING (no offers yet) or ACCEPTED (offer accepted but not yet assigned)
        // Only hide shipments that are ASSIGNED (assignedCarrierId != null)
        final unassignedShipments = deduplicatedShipments
          .where((s) => 
            s.assignedCarrierId == null && 
            (s.status == ShipmentStatus.pending || s.status == ShipmentStatus.accepted)
          )
          .toList();

      print(
        '📦 Filtered to ${unassignedShipments.length} UNASSIGNED shipments available for offers',
      );

      _shipments = unassignedShipments;

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
      final models = await repository.getCarrierAssignedShipmentsById(
        carrierId,
      );
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

  // Remove duplicate shipments by numeric id while preserving order.
  // Logs duplicates for diagnostics.
  void _dedupeShipmentsById() {
    final seen = <int>{};
    final unique = <Shipment>[];
    for (final s in _shipments) {
      final id = s.id;
      if (id == null) {
        unique.add(s);
        continue;
      }
      if (!seen.contains(id)) {
        seen.add(id);
        unique.add(s);
      } else {
        print('⚠️ ShipmentProvider: removed duplicate shipment id=$id');
      }
    }
    _shipments = unique;
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

  Future<Shipment> loadShipmentDetail(int shipmentId) async {
    _setLoading(true);
    _clearError();

    try {
      final shipment = await repository.getShipment(shipmentId);
      _upsertShipment(shipment);
      _activeShipment = shipment;
      notifyListeners();
      return shipment;
    } catch (e) {
      _setError('Failed to load shipment details: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Accept shipment (carrier action)
  // Note: Shipment assignment happens via offer acceptance flow in the current implementation.
  // This method provides an alternative direct assignment flow (not currently used).
  // The standard flow is: Carrier submits offer → Shipper accepts → Backend assigns carrier
  Future<void> acceptShipment(int shipmentId) async {
    throw Exception(
      'Direct shipment acceptance is disabled. Submit an offer and wait for shipper approval.',
    );
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

      // Defensive check: ensure backend did NOT mutate the shipment state
      // during offer creation (it should only create an offer record).
      try {
        final latestShipment = await repository.getShipment(shipmentId);
        // If backend unexpectedly assigned the shipment or changed status
        // away from PENDING, surface a diagnostic and update local state.
        if (latestShipment.assignedCarrierId != null) {
          print('❗️[Defensive] Backend assigned carrier during offer submission for shipment $shipmentId - assignedCarrierId=${latestShipment.assignedCarrierId}');
          _upsertShipment(latestShipment);
          _setError('Backend assigned a carrier during offer submission. Contact support.');
        } else if (latestShipment.status != ShipmentStatus.pending) {
          print('❗️[Defensive] Backend changed shipment status during offer submission for shipment $shipmentId -> ${latestShipment.status.displayName}');
          _upsertShipment(latestShipment);
          _setError('Shipment status changed during offer submission: ${latestShipment.status.displayName}');
        }
      } catch (e) {
        // If we cannot fetch the shipment, log but don't block the offer flow.
        print('⚠️ [Defensive] Failed to re-fetch shipment $shipmentId after offer creation: $e');
      }

      notifyListeners();
    } catch (e) {
      // Rollback optimistic update
      _offersCache[shipmentId]?.removeWhere((o) => o.id == tempOffer.id);
      _setError('Failed to submit offer: ${e.toString()}');
      notifyListeners();
      rethrow;
    } finally {
      _submittingOffers.remove(shipmentId);
      notifyListeners();
    }
  }

  /// Add an optimistic (temporary) offer to the local offers cache without
  /// making an API call. Used when another flow already submitted the offer
  /// to the backend but we want the UI to reflect the new offer immediately.
  void addOptimisticOffer({
    required int shipmentId,
    required double price,
  }) {
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
  }

  Future<void> assignCarrier({
    required int shipmentId,
    required int carrierId,
  }) async {
    throw Exception(
      'Direct carrier assignment is disabled. Accept a carrier offer from the review screen.',
    );
  }

  // Update shipment status (carrier action)
  Future<void> updateShipmentStatus(
    int shipmentId,
    ShipmentStatus newStatus, {
    String? location,
  }
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedShipment = await repository.updateShipmentStatus(
        shipmentId: shipmentId,
        status: newStatus,
        location: location ?? _activeShipment?.destination ?? 'Unknown',
      );
      final index = _shipments.indexWhere((s) => s.id == shipmentId);
      if (index != -1) {
        _shipments[index] = updatedShipment;
      }
      final assignedIndex = _assignedShipments.indexWhere(
        (s) => s.id == shipmentId,
      );
      if (assignedIndex != -1) {
        _assignedShipments[assignedIndex] = updatedShipment;
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
      print(
        '📦 Fetching my shipments (role-aware) using /shipment/my endpoint...',
      );

      final statuses = <ShipmentStatus>[
        ShipmentStatus.pending,
        ShipmentStatus.accepted,
        ShipmentStatus.assigned,
        ShipmentStatus.pickedUp,
        ShipmentStatus.inTransit,
        ShipmentStatus.arrivedAtDestination,
        ShipmentStatus.delivered,
        ShipmentStatus.paymentPending,
        ShipmentStatus.completed,
      ];
      final byId = <int, Shipment>{};
      final withoutId = <Shipment>[];

      for (final status in statuses) {
        final statusShipments = await repository.getMyShipmentsByStatus(
          status: status,
          page: 0,
          size: 50,
        );
        for (final shipment in statusShipments) {
          final id = shipment.id;
          if (id == null) {
            withoutId.add(shipment);
          } else {
            byId[id] = shipment;
          }
        }
      }

      _shipments = [...byId.values, ...withoutId];
      _currentPage = 0;
      _totalPages = 1;
      _hasMorePages = false;
      _dashboardInformation = _dashboardFromShipments(
        _shipments,
        fallback: _dashboardInformation,
      );

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
  Future<void> loadShipmentsPaginated({
    int page = 0,
    int size = 20,
    bool append = false,
  }) async {
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
        // Deduplicate after appending pages to avoid pagination overlap duplicates
        _dedupeShipmentsById();
      } else {
        // Replace list
        _shipments = paginatedResponse.shipments;
        _dedupeShipmentsById();
      }

      _currentPage = paginatedResponse.currentPage;
      _totalPages = paginatedResponse.totalPages;
      _hasMorePages = paginatedResponse.hasMore;
      _pageSize = size;
      _dashboardInformation = _dashboardFromShipments(
        _shipments,
        fallback: _dashboardInformation,
      );

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
  Future<void> cancelShipmentOffer({
    required int shipmentId,
    required int shipmentOfferId,
  }) async {
    // Re-check shipment state to avoid cancelling after assignment (race condition)
    try {
      final latest = await repository.getShipment(shipmentId);
      if (latest.assignedCarrierId != null || latest.status == ShipmentStatus.assigned) {
        throw Exception('Cannot cancel offer: shipment already assigned.');
      }
    } catch (e) {
      // If unable to fetch shipment, fail-safe: abort cancellation to avoid unintended state changes
      _setError('Unable to verify shipment status before cancelling offer: ${e.toString()}');
      rethrow;
    }
    if (_mutatingOfferIds.contains(shipmentOfferId)) return;
    _mutatingOfferIds.add(shipmentOfferId);
    _clearError();

    final existing = _offersCache[shipmentId] ?? [];
    final removed = existing.where((o) => o.id == shipmentOfferId).toList();
    if (removed.isEmpty) {
      _mutatingOfferIds.remove(shipmentOfferId);
      return;
    }

    // Optimistic removal
    _offersCache[shipmentId] = existing
        .where((o) => o.id != shipmentOfferId)
        .toList();
    notifyListeners();

    try {
      await repository.cancelShipmentOffer(shipmentOfferId);
      final fresh = await repository.getShipmentOffers(shipmentId);
      _offersCache[shipmentId] = fresh;
      notifyListeners();
    } catch (e) {
      // rollback
      _offersCache[shipmentId] = [
        ..._offersCache[shipmentId] ?? [],
        ...removed,
      ];
      _setError('Failed to cancel offer: ${e.toString()}');
      notifyListeners();
      rethrow;
    } finally {
      _mutatingOfferIds.remove(shipmentOfferId);
      notifyListeners();
    }
  }

  /// Accept a carrier offer from the shipper offer review screen.
  /// CRITICAL BUSINESS RULE: Only one carrier can be assigned per shipment.
  Future<void> acceptShipmentOffer({
    required int shipmentId,
    required int shipmentOfferId,
    required int carrierId,
  }) async {
    if (carrierId <= 0) {
      throw Exception('Carrier profile id is missing from the selected offer.');
    }
    if (_mutatingOfferIds.contains(shipmentOfferId)) return;

    _mutatingOfferIds.add(shipmentOfferId);
    _clearError();
    notifyListeners();

    try {
      // CRITICAL: Verify shipment is still unassigned before attempting assignment
      // This prevents race condition where multiple carriers could be assigned
      print('🔒 Pre-assignment check: verifying shipment $shipmentId is still unassigned');
      final currentShipment = await repository.getShipment(shipmentId);
      
      if (currentShipment.assignedCarrierId != null) {
        print('⚠️ Assignment blocked: shipment $shipmentId already has assignedCarrierId=${currentShipment.assignedCarrierId}');
        throw Exception(
          'This shipment has already been assigned to another carrier. '
          'Only one carrier can be assigned per shipment.',
        );
      }
      
      if (currentShipment.status == ShipmentStatus.assigned) {
        print('⚠️ Assignment blocked: shipment $shipmentId status is already ASSIGNED');
        throw Exception(
          'This shipment status is already ASSIGNED. '
          'Cannot accept additional offers.',
        );
      }

      print('✅ Pre-assignment check passed: shipment is unassigned, proceeding with assignment');

      // Proceed with assignment
      await repository.assignCarrier(
        shipmentId: shipmentId,
        carrierId: carrierId,
      );

      // Refresh shipment to get updated state from backend
      final refreshedShipment = await repository.getShipment(shipmentId);
      _upsertShipment(refreshedShipment);
      _activeShipment = refreshedShipment;
      
      // Clear offers cache - backend should auto-reject other offers
      _offersCache.remove(shipmentId);
      
      print('✅ Assignment completed: shipment $shipmentId assigned to carrier $carrierId');
      print('   Shipment assignedCarrierId: ${refreshedShipment.assignedCarrierId}');
      print('   Shipment status: ${refreshedShipment.status.displayName}');
      
      notifyListeners();
    } catch (e) {
      print('❌ Assignment failed for shipment $shipmentId: $e');
      _setError('Failed to accept offer: ${e.toString()}');
      rethrow;
    } finally {
      _mutatingOfferIds.remove(shipmentOfferId);
      notifyListeners();
    }
  }

  void _upsertShipment(Shipment shipment) {
    final shipmentId = shipment.id;
    if (shipmentId == null) return;

    final shipmentIndex = _shipments.indexWhere(
      (item) => item.id == shipmentId,
    );
    if (shipmentIndex == -1) {
      _shipments.add(shipment);
    } else {
      _shipments[shipmentIndex] = shipment;
    }

    final assignedIndex = _assignedShipments.indexWhere(
      (item) => item.id == shipmentId,
    );
    if (assignedIndex != -1) {
      _assignedShipments[assignedIndex] = shipment;
    }
    _dashboardInformation = _dashboardFromShipments(
      _shipments,
      fallback: _dashboardInformation,
    );
  }

  DashboardInformation _dashboardFromShipments(
    List<Shipment> shipments, {
    required DashboardInformation fallback,
  }) {
    if (shipments.isEmpty) return fallback;

    final pending = shipments
        .where((shipment) => shipment.status == ShipmentStatus.pending)
        .length;
    final assigned = shipments
        .where((shipment) => shipment.status == ShipmentStatus.assigned)
        .length;
    final delivered = shipments
        .where((shipment) => shipment.status == ShipmentStatus.delivered)
        .length;
    final completed = shipments
        .where((shipment) => shipment.status == ShipmentStatus.completed)
        .length;
    final inTransit = shipments
        .where(
          (shipment) =>
              shipment.status == ShipmentStatus.pickedUp ||
              shipment.status == ShipmentStatus.inTransit ||
              shipment.status == ShipmentStatus.arrivedAtDestination,
        )
        .length;
    final paymentPending = shipments
        .where((shipment) => shipment.status == ShipmentStatus.paymentPending)
        .length;
    final active = shipments
        .where(
          (shipment) =>
              shipment.status == ShipmentStatus.assigned ||
              shipment.status == ShipmentStatus.pickedUp ||
              shipment.status == ShipmentStatus.inTransit ||
              shipment.status == ShipmentStatus.arrivedAtDestination ||
              shipment.status == ShipmentStatus.paymentPending,
        )
        .length;
    final fragile = shipments.where((shipment) => shipment.fragile).length;

    return DashboardInformation(
      pendingShipments: pending,
      assignedShipments: assigned,
      deliveredShipments: delivered,
      completedShipments: completed,
      inTransitShipments: inTransit,
      paymentPendingShipments: paymentPending,
      availableLoads: pending,
      activeLoads: active,
      fragileShipments: fragile,
      nonFragileShipments: shipments.length - fragile,
    );
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
      _assignedShipments = await repository.getCarrierAssignedShipmentsById(
        carrierId,
      );
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
