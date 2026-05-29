import '../../domain/entities/shipment.dart';
import '../../domain/entities/dashboard_information.dart';
import '../../domain/entities/paginated_shipments.dart';
import '../../domain/enums/shipment_status.dart';
import '../../domain/repositories/shipment_repository.dart';
import '../../../auth/data/storage/token_storage.dart';
import '../../../shipment_offer/data/models/shipment_offer_model.dart';
import '../models/dashboard_information_model.dart';
import '../models/create_shipment_request.dart';
import 'package:memilogistics_app/features/shipment/data/models/shipment_statistics_model.dart';
import '../mappers/shipment_mapper.dart';
import '../services/shipment_api_service_real.dart';

class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentApiServiceReal apiService;
  final TokenStorage tokenStorage;

  ShipmentRepositoryImpl({
    required this.apiService,
    required this.tokenStorage,
  });

  @override
  Future<Shipment> createShipment(Shipment shipment, {int? shipperId}) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to create a shipment');
    }

    // Validate shipper ID is provided
    if (shipperId == null) {
      throw Exception('Shipper ID is required to create a shipment. Please create your shipper profile first.');
    }

    // Convert Shipment entity to CreateShipmentRequest
    final request = _toCreateRequest(shipment, shipperId);

    // Call backend API
    final model = await apiService.createShipment(request);

    // Convert ShipmentModel to Shipment entity
    return ShipmentMapper.toEntity(model);
  }

  Future<List<Shipment>> listShipments({int page = 0, int size = 20}) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to view shipments');
    }

    final models = await apiService.listShipments(page: page, size: size);
    return models.map((model) => ShipmentMapper.toEntity(model)).toList();
  }

  @override
  Future<PaginatedShipments> listShipmentsPaginated({
    int page = 0,
    int size = 20,
  }) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to view shipments');
    }

    final paginatedResponse = await apiService.listShipmentsPaginated(
      page: page,
      size: size,
    );

    return PaginatedShipments(
      totalElements: paginatedResponse.totalElements,
      totalPages: paginatedResponse.totalPages,
      currentPage: paginatedResponse.number,
      pageSize: paginatedResponse.size,
      isFirst: paginatedResponse.first,
      isLast: paginatedResponse.last,
      shipments: paginatedResponse.content
          .map((model) => ShipmentMapper.toEntity(model))
          .toList(),
    );
  }

  @override
  Future<PaginatedShipments> getShipperShipmentsPaginated({
    int page = 0,
    int size = 20,
  }) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to view your shipments');
    }

    final paginatedResponse = await apiService.getShipperShipmentsPaginated(
      page: page,
      size: size,
    );

    return PaginatedShipments(
      totalElements: paginatedResponse.totalElements,
      totalPages: paginatedResponse.totalPages,
      currentPage: paginatedResponse.number,
      pageSize: paginatedResponse.size,
      isFirst: paginatedResponse.first,
      isLast: paginatedResponse.last,
      shipments: paginatedResponse.content
          .map((model) => ShipmentMapper.toEntity(model))
          .toList(),
    );
  }

  Future<Shipment> getShipment(int shipmentId) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to view shipment details');
    }

    final model = await apiService.getShipment(shipmentId);
    return ShipmentMapper.toEntity(model);
  }

  Future<void> deleteShipment(int shipmentId) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to delete a shipment');
    }

    await apiService.deleteShipment(shipmentId);
  }

  @override
  Future<void> offerShipment({
    required int shipmentId,
    required double price,
  }) async {
    await _requireAccessToken('submit an offer');
    await apiService.offerShipment(shipmentId: shipmentId, price: price);
  }

  @override
  Future<void> cancelShipmentOffer(int shipmentOfferId) async {
    await _requireAccessToken('cancel an offer');
    await apiService.cancelShipmentOffer(shipmentOfferId);
  }

  @override
  Future<void> assignCarrier({
    required int shipmentId,
    required int carrierId,
  }) async {
    await _requireAccessToken('assign a carrier');
    await apiService.assignCarrier(
      shipmentId: shipmentId,
      carrierId: carrierId,
    );
  }

  @override
  Future<Shipment> updateShipmentStatus({
    required int shipmentId,
    required ShipmentStatus status,
    required String location,
  }) async {
    await _requireAccessToken('update shipment status');
    final model = await apiService.updateStatus(
      shipmentId: shipmentId,
      status: status.backendValue,
      location: location,
    );
    return ShipmentMapper.toEntity(model);
  }

  @override
  Future<List<Map<String, dynamic>>> getShipmentEvents(int shipmentId) async {
    await _requireAccessToken('view shipment events');
    return apiService.getShipmentEvents(shipmentId);
  }

  @override
  Future<List<ShipmentOfferModel>> getShipmentOffers(int shipmentId) async {
    await _requireAccessToken('view shipment offers');
    return apiService.getShipmentOffers(shipmentId);
  }

  @override
  Future<ShipmentStatisticsDto> getShipmentStatistics() async {
    await _requireAccessToken('view shipment statistics');
    final json = await apiService.getShipmentStatistics();
    return ShipmentStatisticsDto.fromJson(json);
  }

  @override
  Future<DashboardInformation> getDashboardInformation() async {
    await _requireAccessToken('view dashboard information');
    final json = await apiService.getDashboard();
    return DashboardInformationModel.fromJson(json).toEntity();
  }

  @override
  Future<List<Shipment>> getCarrierAssignedShipments() async {
    await _requireAccessToken('view assigned shipments');
    final models = await apiService.getCarrierAssignedShipments();
    return models.map((m) => ShipmentMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Shipment>> getCarrierAssignedShipmentsById(int carrierId) async {
    await _requireAccessToken('view assigned shipments');
    final models = await apiService.getCarrierAssignedShipmentsById(carrierId);
    return models.map((m) => ShipmentMapper.toEntity(m)).toList();
  }

  Future<void> _requireAccessToken(String action) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to $action');
    }
  }

  // Helper to convert Shipment entity to CreateShipmentRequest
  CreateShipmentRequest _toCreateRequest(Shipment shipment, int shipperId) {
    // Format date to string (YYYY-MM-DD)
    String deliveryDate = '';
    if (shipment.pickupDate != null) {
      final date = shipment.pickupDate!;
      deliveryDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    return CreateShipmentRequest(
      shipperId: shipperId,  // Include shipper ID
      origin: shipment.origin,
      destination: shipment.destination,
      weightKg: shipment.weightKg,
      deliveryDate: deliveryDate,
      fragile: shipment.fragile,
      shipmentItem: shipment.shipmentItem ?? 'General Cargo',
      description: shipment.description,
    );
  }
}
