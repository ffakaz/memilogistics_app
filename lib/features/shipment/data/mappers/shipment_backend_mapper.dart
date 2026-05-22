// lib/features/shipment/data/mappers/shipment_backend_mapper.dart

import '../../domain/entities/location.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/safety_option.dart';
import '../../domain/enums/shipment_type.dart';
import '../../domain/enums/weight_unit.dart';
import '../models/create_shipment_request.dart';
import '../models/shipment_response_model.dart';
import 'delivery_confirmation_mapper.dart';
import 'payment_record_mapper.dart';
import 'shipper_profile_mapper.dart';
import 'carrier_profile_mapper.dart';
import 'shipment_offer_mapper.dart';
import 'shipment_event_mapper.dart';

class ShipmentBackendMapper {
  /// Convert frontend Shipment to backend CreateShipmentRequest
  static CreateShipmentRequest toCreateRequest(Shipment shipment) {
    return CreateShipmentRequest(
      origin: shipment.pickupLocation.address,
      destination: shipment.destinationLocation.address,
      weightKg: _convertToKg(shipment.amount, shipment.unit),
      deliveryDate: shipment.pickupDate,
      fragile: shipment.safetyOption == SafetyOption.fragile,
      shipmentItem: _getShipmentItem(shipment.shipmentType),
      description: shipment.description,
    );
  }

  /// Convert backend ShipmentResponseModel to frontend Shipment
  static Shipment fromResponseModel(ShipmentResponseModel model) {
    return Shipment(
      id: model.id,
      trackingNumber: model.trackingNumber,
      shipperName:
          model.shipper?['companyName'] as String? ??
          model.shipper?['businessName'] as String? ??
          'Unknown Shipper',
      shipmentType: _parseShipmentType(model.shipmentItem),
      amount: model.weightKg,
      unit: WeightUnit.kg,
      pickupLocation: Location(
        address: model.origin,
        city: _extractCity(model.origin),
        state: _extractState(model.origin),
      ),
      destinationLocation: Location(
        address: model.destination,
        city: _extractCity(model.destination),
        state: _extractState(model.destination),
      ),
      pickupDate: model.pickupDate ?? model.createdAt ?? DateTime.now(),
      safetyOption: model.fragile ? SafetyOption.fragile : SafetyOption.normal,
      status: model.status,
      description: model.description,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      completedAt: model.completedAt,
      volume: model.volume,
      shipmentItem: model.shipmentItem,
      weightKg: model.weightKg,
      origin: model.origin,
      destination: model.destination,
      estimatedDeliveryDate: model.estimatedDeliveryDate,
      fragile: model.fragile,
      deliveryConfirmation: model.deliveryConfirmation != null
          ? DeliveryConfirmationMapper.fromJson(model.deliveryConfirmation!)
          : null,
      paymentRecord: model.paymentRecord != null
          ? PaymentRecordMapper.fromJson(model.paymentRecord!)
          : null,
      shipper: model.shipper != null
          ? ShipperProfileMapper.fromJson(model.shipper!)
          : null,
      assignedCarrier: model.assignedCarrier != null
          ? CarrierProfileMapper.fromJson(model.assignedCarrier!)
          : null,
      shipmentOffers: model.shipmentOffers != null
          ? model.shipmentOffers!
                .map((json) => ShipmentOfferMapper.fromJson(json))
                .toList()
          : null,
      shipmentEvents: model.shipmentEvents != null
          ? model.shipmentEvents!
                .map((json) => ShipmentEventMapper.fromJson(json))
                .toList()
          : null,
    );
  }

  /// Convert weight to kilograms
  static double _convertToKg(double amount, WeightUnit unit) {
    switch (unit) {
      case WeightUnit.kg:
        return amount;
      case WeightUnit.ton:
        return amount * 1000;
      case WeightUnit.lbs:
        return amount * 0.453592;
    }
  }

  /// Get shipment item string from shipment type
  static String _getShipmentItem(ShipmentType type) {
    switch (type) {
      case ShipmentType.dryGoods:
        return 'Dry Goods';
      case ShipmentType.electronics:
        return 'Electronics';
      case ShipmentType.fuel:
        return 'Fuel';
      case ShipmentType.fullTruckLoad:
        return 'Full Truck Load';
      case ShipmentType.lessThanTruckLoad:
        return 'Less Than Truck Load';
      case ShipmentType.partialTruckLoad:
        return 'Partial Truck Load';
    }
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
    return ShipmentType.dryGoods; // Default fallback
  }

  /// Extract city from address string (simple heuristic)
  static String? _extractCity(String address) {
    // Try to extract city from "City, State" format
    final parts = address.split(',');
    if (parts.length >= 2) {
      return parts[parts.length - 2].trim();
    }
    return null;
  }

  /// Extract state from address string (simple heuristic)
  static String? _extractState(String address) {
    // Try to extract state from "City, State" format
    final parts = address.split(',');
    if (parts.length >= 2) {
      final lastPart = parts.last.trim();
      // Extract state code (2 letters) if present
      final stateMatch = RegExp(r'\b([A-Z]{2})\b').firstMatch(lastPart);
      return stateMatch?.group(1);
    }
    return null;
  }
}
