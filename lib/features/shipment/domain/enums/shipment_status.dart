enum ShipmentStatus {
  pending,
  accepted,
  assigned,
  pickedUp,
  inTransit,
  arrivedAtDestination,
  delivered,
  completed,
  cancelled,
}

extension ShipmentStatusX on ShipmentStatus {
  String get backendValue {
    switch (this) {
      case ShipmentStatus.pending:
        return 'PENDING';
      case ShipmentStatus.accepted:
        return 'ACCEPTED';
      case ShipmentStatus.assigned:
        return 'ASSIGNED';
      case ShipmentStatus.pickedUp:
        return 'PICKED_UP';
      case ShipmentStatus.inTransit:
        return 'IN_TRANSIT';
      case ShipmentStatus.arrivedAtDestination:
        return 'ARRIVED_AT_DESTINATION';
      case ShipmentStatus.delivered:
        return 'DELIVERED';
      case ShipmentStatus.completed:
        return 'COMPLETED';
      case ShipmentStatus.cancelled:
        return 'CANCELLED';
    }
  }
}