import 'package:memilogistics_app/core/network/fake_api_client.dart';
import 'package:memilogistics_app/features/shipment/data/services/shipment_api_service_adapter.dart';

void main() async {
  final apiClient = FakeApiClient();
  final adapter = ShipmentApiServiceAdapter(apiClient: apiClient);

  final shipment = {
    'shipperName': 'Test Shipper',
    'shipmentType': 'dryGoods',
    'amount': 10.5,
    'unit': 'kg',
    'pickupPoint': 'Origin Address',
    'destination': 'Destination Address',
    'pickupDate': DateTime.now().toIso8601String(),
    'safetyOption': 'NORMAL',
  };

  try {
    await adapter.createShipment(body: shipment, accessToken: 'test_token');
    print('createShipment: SUCCESS');
  } catch (e, st) {
    print('createShipment: FAILED - $e');
    print(st);
  }
}
