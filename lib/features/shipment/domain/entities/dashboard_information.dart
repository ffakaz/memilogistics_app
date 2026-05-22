class DashboardInformation {
  final int pendingShipments;
  final int completedShipments;
  final int fragileShipments;
  final int nonFragileShipments;

  const DashboardInformation({
    required this.pendingShipments,
    required this.completedShipments,
    required this.fragileShipments,
    required this.nonFragileShipments,
  });

  int get totalShipments =>
      pendingShipments +
      completedShipments +
      fragileShipments +
      nonFragileShipments;

  static const empty = DashboardInformation(
    pendingShipments: 0,
    completedShipments: 0,
    fragileShipments: 0,
    nonFragileShipments: 0,
  );
}
