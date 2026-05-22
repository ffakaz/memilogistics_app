import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/dashboard_information.dart';

class DashboardInformationModel {
  final int pendingShipments;
  final int completedShipments;
  final int fragileShipments;
  final int nonFragileShipments;

  const DashboardInformationModel({
    required this.pendingShipments,
    required this.completedShipments,
    required this.fragileShipments,
    required this.nonFragileShipments,
  });

  factory DashboardInformationModel.fromJson(Map<String, dynamic> json) {
    return DashboardInformationModel(
      pendingShipments: JsonParsing.asInt(json['pendingShipments']),
      completedShipments: JsonParsing.asInt(json['completedShipments']),
      fragileShipments: JsonParsing.asInt(json['fragileShipments']),
      nonFragileShipments: JsonParsing.asInt(json['nonFragileShipments']),
    );
  }

  DashboardInformation toEntity() {
    return DashboardInformation(
      pendingShipments: pendingShipments,
      completedShipments: completedShipments,
      fragileShipments: fragileShipments,
      nonFragileShipments: nonFragileShipments,
    );
  }
}
