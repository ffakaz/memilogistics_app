import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/dashboard_information.dart';

class DashboardInformationModel {
  final int pendingShipments;
  final int assignedShipments;
  final int deliveredShipments;
  final int completedShipments;
  final int inTransitShipments;
  final int paymentPendingShipments;
  final int availableLoads;
  final int activeLoads;
  final int fragileShipments;
  final int nonFragileShipments;

  const DashboardInformationModel({
    required this.pendingShipments,
    required this.assignedShipments,
    required this.deliveredShipments,
    required this.completedShipments,
    this.inTransitShipments = 0,
    this.paymentPendingShipments = 0,
    required this.availableLoads,
    required this.activeLoads,
    required this.fragileShipments,
    required this.nonFragileShipments,
  });

  factory DashboardInformationModel.fromJson(Map<String, dynamic> json) {
    final pending = JsonParsing.asInt(
      json['pendingShipments'] ?? json['pending'] ?? json['availableLoads'],
    );
    final assigned = JsonParsing.asInt(
      json['assignedShipments'] ?? json['assigned'] ?? json['activeLoads'],
    );
    final delivered = JsonParsing.asInt(
      json['deliveredShipments'] ?? json['delivered'] ?? json['deliveredLoads'],
    );
    final completed = JsonParsing.asInt(
      json['completedShipments'] ?? json['completed'] ?? json['completedLoads'],
    );
    final inTransit = JsonParsing.asInt(
      json['inTransitShipments'] ?? json['inTransit'] ?? json['inTransitLoads'],
    );
    final paymentPending = JsonParsing.asInt(
      json['paymentPendingShipments'] ??
          json['paymentPending'] ??
          json['paymentPendingLoads'],
    );

    return DashboardInformationModel(
      pendingShipments: pending,
      assignedShipments: assigned,
      deliveredShipments: delivered,
      completedShipments: completed,
      inTransitShipments: inTransit,
      paymentPendingShipments: paymentPending,
      availableLoads: JsonParsing.asInt(json['availableLoads'] ?? pending),
      activeLoads: JsonParsing.asInt(json['activeLoads'] ?? assigned),
      fragileShipments: JsonParsing.asInt(json['fragileShipments']),
      nonFragileShipments: JsonParsing.asInt(json['nonFragileShipments']),
    );
  }

  DashboardInformation toEntity() {
    return DashboardInformation(
      pendingShipments: pendingShipments,
      assignedShipments: assignedShipments,
      deliveredShipments: deliveredShipments,
      completedShipments: completedShipments,
      inTransitShipments: inTransitShipments,
      paymentPendingShipments: paymentPendingShipments,
      availableLoads: availableLoads,
      activeLoads: activeLoads,
      fragileShipments: fragileShipments,
      nonFragileShipments: nonFragileShipments,
    );
  }
}
