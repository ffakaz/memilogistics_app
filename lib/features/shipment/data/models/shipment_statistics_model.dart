// lib/features/shipment/data/models/shipment_statistics_model.dart

/// Data model for shipment statistics matching backend API response
class ShipmentStatisticsDto {
  final int pendingShipments;
  final int completedShipments;
  final int fragileShipments;
  final int nonFragileShipments;

  const ShipmentStatisticsDto({
    required this.pendingShipments,
    required this.completedShipments,
    required this.fragileShipments,
    required this.nonFragileShipments,
  });

  factory ShipmentStatisticsDto.fromJson(Map<String, dynamic> json) {
    return ShipmentStatisticsDto(
      pendingShipments: json['pendingShipments'] as int? ?? 0,
      completedShipments: json['completedShipments'] as int? ?? 0,
      fragileShipments: json['fragileShipments'] as int? ?? 0,
      nonFragileShipments: json['nonFragileShipments'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendingShipments': pendingShipments,
      'completedShipments': completedShipments,
      'fragileShipments': fragileShipments,
      'nonFragileShipments': nonFragileShipments,
    };
  }

  /// Total number of shipments
  int get totalShipments => pendingShipments + completedShipments;

  /// Completion rate as percentage (0-100)
  double get completionRate {
    if (totalShipments == 0) return 0.0;
    return (completedShipments / totalShipments) * 100;
  }

  /// Fragile shipments as percentage (0-100)
  double get fragilePercentage {
    if (totalShipments == 0) return 0.0;
    return (fragileShipments / totalShipments) * 100;
  }

  @override
  String toString() {
    return 'ShipmentStatistics(pending: $pendingShipments, completed: $completedShipments, fragile: $fragileShipments, nonFragile: $nonFragileShipments)';
  }
}
