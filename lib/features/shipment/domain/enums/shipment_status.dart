enum ShipmentStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),        // NEW
  assigned('ASSIGNED'),
  pickedUp('PICKED_UP'),
  inTransit('IN_TRANSIT'),
  arrivedAtDestination('ARRIVED_AT_DESTINATION'),
  delivered('DELIVERED'),
  completed('COMPLETED');
  
  final String backendValue;
  const ShipmentStatus(this.backendValue);
  
  String get displayName {
    switch (this) {
      case ShipmentStatus.pending:
        return 'Pending';
      case ShipmentStatus.accepted:
        return 'Accepted';
      case ShipmentStatus.assigned:
        return 'Assigned';
      case ShipmentStatus.pickedUp:
        return 'Picked Up';
      case ShipmentStatus.inTransit:
        return 'In Transit';
      case ShipmentStatus.arrivedAtDestination:
        return 'Arrived';
      case ShipmentStatus.delivered:
        return 'Delivered';
      case ShipmentStatus.completed:
        return 'Completed';
    }
  }
}