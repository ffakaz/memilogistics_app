import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../../domain/repositories/shipment_repository.dart';
import '../../../auth/data/storage/token_storage.dart';
import '../mappers/shipment_backend_mapper.dart';
import '../services/shipment_api_service_real.dart';

class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentApiServiceReal apiService;
  final TokenStorage tokenStorage;

  ShipmentRepositoryImpl({
    required this.apiService,
    required this.tokenStorage,
  });

  @override
  Future<Shipment> createShipment(Shipment shipment) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to create a shipment');
    }

    // Convert frontend Shipment to backend CreateShipmentRequest
    final request = ShipmentBackendMapper.toCreateRequest(shipment);
    
    // Call backend API
    final response = await apiService.createShipment(request);
    
    // Convert backend response to frontend Shipment
    return ShipmentBackendMapper.fromResponseModel(response);
  }

  Future<List<Shipment>> listShipments({int page = 0, int size = 20}) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to view shipments');
    }

    final responses = await apiService.listShipments(page: page, size: size);
    return responses
        .map((response) => ShipmentBackendMapper.fromResponseModel(response))
        .toList();
  }

  Future<Shipment> getShipment(int shipmentId) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to view shipment details');
    }

    final response = await apiService.getShipment(shipmentId);
    return ShipmentBackendMapper.fromResponseModel(response);
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
    await apiService.assignCarrier(shipmentId: shipmentId, carrierId: carrierId);
  }

  @override
  Future<Shipment> updateShipmentStatus({
    required int shipmentId,
    required ShipmentStatus status,
    required String location,
  }) async {
    await _requireAccessToken('update shipment status');
    final response = await apiService.updateStatus(
      shipmentId: shipmentId,
      status: status.backendValue,
      location: location,
    );
    return ShipmentBackendMapper.fromResponseModel(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getShipmentEvents(int shipmentId) async {
    await _requireAccessToken('view shipment events');
    return apiService.getShipmentEvents(shipmentId);
  }

  Future<void> _requireAccessToken(String action) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('You must be logged in to $action');
    }
  }
}
