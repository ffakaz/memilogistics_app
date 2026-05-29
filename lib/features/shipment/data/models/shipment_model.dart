import '../../../../core/utils/json_parsing.dart';
import '../../domain/enums/shipment_status.dart';

class ShipmentModel {
  final int id;
  final String? trackingNumber;
  final String origin;
  final String destination;
  final double weightKg;
  final double? volume;
  final ShipmentStatus status;
  final String? pickupDate;
  final String? estimatedDeliveryDate;
  final String? shipmentItem;
  final String? description;
  final bool fragile;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final int? shipperId;
  final int? assignedCarrierId;

  const ShipmentModel({
    required this.id,
    required this.trackingNumber,
    required this.origin,
    required this.destination,
    required this.weightKg,
    this.volume,
    required this.status,
    this.pickupDate,
    this.estimatedDeliveryDate,
    this.shipmentItem,
    this.description,
    required this.fragile,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.shipperId,
    this.assignedCarrierId,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: JsonParsing.asInt(json['id'] ?? json['shipmentId']),  // Handle both 'id' and 'shipmentId'
      trackingNumber: json['trackingNumber'] as String?,
      origin: json['origin'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      weightKg: JsonParsing.asDouble(json['weightKg']),
      volume: json['volume'] != null ? JsonParsing.asDouble(json['volume']) : null,
      status: _parseStatus(JsonParsing.asString(json['status'], fallback: 'PENDING')),
      pickupDate: json['pickupDate'] as String?,
      estimatedDeliveryDate: json['estimatedDeliveryDate'] as String?,
      shipmentItem: json['shipmentItem'] as String?,
      description: json['description'] as String?,
      fragile: json['fragile'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      shipperId: JsonParsing.asIntOrNull(json['shipperId']),
      assignedCarrierId: JsonParsing.asIntOrNull(json['assignedCarrierId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'origin': origin,
      'destination': destination,
      'weightKg': weightKg,
      if (volume != null) 'volume': volume,
      'status': status.backendValue,
      if (pickupDate != null) 'pickupDate': pickupDate,
      if (estimatedDeliveryDate != null) 'estimatedDeliveryDate': estimatedDeliveryDate,
      if (shipmentItem != null) 'shipmentItem': shipmentItem,
      if (description != null) 'description': description,
      'fragile': fragile,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (shipperId != null) 'shipperId': shipperId,
      if (assignedCarrierId != null) 'assignedCarrierId': assignedCarrierId,
    };
  }

  static ShipmentStatus _parseStatus(String status) {
    final normalized = status.toUpperCase().replaceAll('-', '_');
    return ShipmentStatus.values.firstWhere(
      (e) => e.backendValue == normalized,
      orElse: () => ShipmentStatus.pending,
    );
  }
}
