class DashboardInformation {
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

  const DashboardInformation({
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

  int get totalShipments =>
      pendingShipments +
      assignedShipments +
      deliveredShipments +
      completedShipments +
      inTransitShipments +
      paymentPendingShipments +
      fragileShipments +
      nonFragileShipments;

  static const empty = DashboardInformation(
    pendingShipments: 0,
    assignedShipments: 0,
    deliveredShipments: 0,
    completedShipments: 0,
    inTransitShipments: 0,
    paymentPendingShipments: 0,
    availableLoads: 0,
    activeLoads: 0,
    fragileShipments: 0,
    nonFragileShipments: 0,
  );
}
