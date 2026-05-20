import '../../domain/enums/shipment_status.dart';

/// ShipmentResponse Model - Matches backend API response
/// This is the SIMPLIFIED response used by most endpoints
/// Does NOT include nested shipmentOffers or shipmentEvents arrays
/// Use separate endpoints to fetch those: GET /api/shipments/{id}/offers and GET /api/shipments/{id}/events
class ShipmentModel {
  final int id; // int64
  final String trackingNumber;
  final String origin;
  final String destination;
  final double weightKg;
  final double? volume;
  final ShipmentStatus status;
  final String? pickupDate; // Format: YYYY-MM-DD (date only)
  final String? estimatedDeliveryDate; // Format: YYYY-MM-DD (date only)
  final String? shipmentItem;
  final String? description;
  final bool fragile;
  final DateTime? createdAt; // Format: ISO 8601 datetime
  final DateTime? updatedAt; // Format: ISO 8601 datetime
  final DateTime? completedAt; // Format: ISO 8601 datetime
  final Map<String, dynamic>? shipper; // ShipperProfileResponse - keep as Map for now
  final Map<String, dynamic>? assignedCarrier; // CarrierCompanyResponse - keep as Map for now

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
    this.shipper,
    this.assignedCarrier,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] as int,
      trackingNumber: json['trackingNumber'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      volume: json['volume'] != null ? (json['volume'] as num).toDouble() : null,
      status: _parseStatus(json['status'] as String),
      pickupDate: json['pickupDate'] as String?,
      estimatedDeliveryDate: json['estimatedDeliveryDate'] as String?,
      shipmentItem: json['shipmentItem'] as String?,
      description: json['description'] as String?,
      fragile: json['fragile'] as bool,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      shipper: json['shipper'] as Map<String, dynamic>?,
      assignedCarrier: json['assignedCarrier'] as Map<String, dynamic>?,
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
      if (shipper != null) 'shipper': shipper,
      if (assignedCarrier != null) 'assignedCarrier': assignedCarrier,
    };
  }

  static ShipmentStatus _parseStatus(String status) {
    // Backend returns uppercase with underscores: PENDING, IN_TRANSIT, etc.
    final normalized = status.toUpperCase().replaceAll('-', '_');
    try {
      return ShipmentStatus.values.firstWhere(
        (e) => e.backendValue == normalized,
        orElse: () => ShipmentStatus.pending,
      );
    } catch (e) {
      return ShipmentStatus.pending;
    }
  }
}