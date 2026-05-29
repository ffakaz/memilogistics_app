// lib/features/shipment/data/mappers/shipment_mapper.dart

import '../../domain/entities/location.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/safety_option.dart';
import '../../domain/enums/shipment_type.dart';
import '../../domain/enums/weight_unit.dart';
import '../models/shipment_model.dart';

class ShipmentMapper {
  /// Convert ShipmentModel to Shipment entity
  static Shipment toEntity(ShipmentModel model) {
    // Parse date strings to DateTime
    DateTime? pickupDate;
    if (model.pickupDate != null) {
      try {
        pickupDate = DateTime.parse(model.pickupDate!);
      } catch (e) {
        pickupDate = null;
      }
    }

    DateTime? estimatedDeliveryDate;
    if (model.estimatedDeliveryDate != null) {
      try {
        estimatedDeliveryDate = DateTime.parse(model.estimatedDeliveryDate!);
      } catch (e) {
        estimatedDeliveryDate = null;
      }
    }

    // Create Location objects from string addresses for backward compatibility
    final pickupLocation = Location(
      address: model.origin,
      city: _extractCity(model.origin),
      state: _extractState(model.origin),
    );

    final destinationLocation = Location(
      address: model.destination,
      city: _extractCity(model.destination),
      state: _extractState(model.destination),
    );

    return Shipment(
      id: model.id,
      trackingNumber: model.trackingNumber,
      origin: model.origin,
      destination: model.destination,
      weightKg: model.weightKg,
      volume: model.volume,
      status: model.status,
      pickupDate: pickupDate,
      estimatedDeliveryDate: estimatedDeliveryDate,
      shipmentItem: model.shipmentItem,
      description: model.description,
      fragile: model.fragile,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      completedAt: model.completedAt,
      shipperId: model.shipperId,
      assignedCarrierId: model.assignedCarrierId,
      // Legacy fields for backward compatibility
      pickupLocation: pickupLocation,
      destinationLocation: destinationLocation,
      amount: model.weightKg,
      unit: WeightUnit.kg,
      safetyOption: model.fragile ? SafetyOption.fragile : SafetyOption.normal,
      shipmentType: _parseShipmentType(model.shipmentItem),
      shipperName: null,
    );
  }

  /// Convert Shipment entity to ShipmentModel
  static ShipmentModel toModel(Shipment entity) {
    // Convert DateTime to date string
    String? pickupDateStr;
    if (entity.pickupDate != null) {
      pickupDateStr = _formatDateString(entity.pickupDate!);
    }

    String? estimatedDeliveryDateStr;
    if (entity.estimatedDeliveryDate != null) {
      estimatedDeliveryDateStr = _formatDateString(entity.estimatedDeliveryDate!);
    }

    return ShipmentModel(
      id: entity.id ?? 0,
      trackingNumber: entity.trackingNumber ?? '',
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
    );
  }

  /// Format DateTime to date string "YYYY-MM-DD"
  static String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse shipment type from item string
  static ShipmentType _parseShipmentType(String? item) {
    if (item == null) return ShipmentType.dryGoods;

    final lowerItem = item.toLowerCase();
    if (lowerItem.contains('dry') || lowerItem.contains('goods')) {
      return ShipmentType.dryGoods;
    } else if (lowerItem.contains('electronic')) {
      return ShipmentType.electronics;
    } else if (lowerItem.contains('fuel')) {
      return ShipmentType.fuel;
    } else if (lowerItem.contains('full') && lowerItem.contains('truck')) {
      return ShipmentType.fullTruckLoad;
    } else if (lowerItem.contains('less') && lowerItem.contains('truck')) {
      return ShipmentType.lessThanTruckLoad;
    } else if (lowerItem.contains('partial') && lowerItem.contains('truck')) {
      return ShipmentType.partialTruckLoad;
    }
    return ShipmentType.dryGoods;
  }

  /// Extract city from address string
  static String? _extractCity(String address) {
    final parts = address.split(',');
    if (parts.length >= 2) {
      return parts[parts.length - 2].trim();
    }
    return null;
  }

  /// Extract state from address string
  static String? _extractState(String address) {
    final parts = address.split(',');
    if (parts.length >= 2) {
      final lastPart = parts.last.trim();
      final stateMatch = RegExp(r'\b([A-Z]{2})\b').firstMatch(lastPart);
      return stateMatch?.group(1);
    }
    return null;
  }
}
