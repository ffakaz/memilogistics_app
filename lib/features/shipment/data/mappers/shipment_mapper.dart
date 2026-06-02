import '../../domain/entities/shipment.dart';

import '../models/shipment_model.dart';

class ShipmentMapper {
  static Shipment toEntity(ShipmentModel model) {
    return Shipment(
      id: model.id,
      trackingNumber: model.trackingNumber,
      origin: model.origin,
      destination: model.destination,
      weightKg: model.weightKg,
      volume: model.volume,
      status: model.status,
      pickupDate: model.pickupDate != null ? DateTime.tryParse(model.pickupDate!) : null,
      estimatedDeliveryDate: model.estimatedDeliveryDate != null
          ? DateTime.tryParse(model.estimatedDeliveryDate!)
          : null,
      shipmentItem: model.shipmentItem,
      description: model.description,
      fragile: model.fragile,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      completedAt: model.completedAt,
      shipperId: model.shipperId,
      assignedCarrierId: model.assignedCarrierId,
      assignedCarrierCompany: model.assignedCarrierCompany,
      assignedCarrierPhone: model.assignedCarrierPhone,
      // Legacy fields kept null for now
      pickupLocation: null,
      destinationLocation: null,
      amount: null,
      unit: null,
      safetyOption: null,
      shipmentType: null,
      shipperName: null,
      assignedCarrierName: model.assignedCarrierName,
    );
  }

  static ShipmentModel toModel(Shipment entity) {
    String? pickupDateStr;
    String? estimatedDeliveryDateStr;

    if (entity.pickupDate != null) {
      final d = entity.pickupDate!;
      pickupDateStr = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    if (entity.estimatedDeliveryDate != null) {
      final d = entity.estimatedDeliveryDate!;
      estimatedDeliveryDateStr = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    return ShipmentModel(
      id: entity.id ?? 0,
      trackingNumber: entity.trackingNumber,
      origin: entity.origin,
      destination: entity.destination,
      weightKg: entity.weightKg,
      volume: entity.volume,
      status: entity.status,
      pickupDate: pickupDateStr,
      estimatedDeliveryDate: estimatedDeliveryDateStr,
      shipmentItem: entity.shipmentItem,
      description: entity.description,
      fragile: entity.fragile,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      completedAt: entity.completedAt,
      shipperId: entity.shipperId,
      assignedCarrierId: entity.assignedCarrierId,
      assignedCarrierName: entity.assignedCarrierName,
      assignedCarrierCompany: entity.assignedCarrierCompany,
      assignedCarrierPhone: entity.assignedCarrierPhone,
    );
  }
}