import 'package:flutter_test/flutter_test.dart';
import 'package:memilogistics_app/core/network/fake_api_client.dart';
import 'package:memilogistics_app/features/shipment/data/services/shipment_api_service_adapter.dart';

void main() {
  test('create shipment via adapter (fake client) succeeds', () async {
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

    await adapter.createShipment(body: shipment, accessToken: 'test_token');
  });
}
