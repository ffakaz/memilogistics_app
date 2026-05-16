import '../../domain/entities/shipment.dart';
import '../models/shipment_model.dart';
import 'location_mapper.dart';

class ShipmentMapper {
  const ShipmentMapper._();

  static ShipmentModel toModel(Shipment shipment) {
    return ShipmentModel(
      shipperName: shipment.shipperName,
      shipmentType: shipment.shipmentType.name,
      amount: shipment.amount,
      unit: shipment.unit.name,
      pickupLocation: LocationMapper.toModel(shipment.pickupLocation),
      destinationLocation: LocationMapper.toModel(shipment.destinationLocation),
      pickupDate: shipment.pickupDate,
      safetyOption: shipment.safetyOption.name,
      status: shipment.status.name,
    );
  }
}
