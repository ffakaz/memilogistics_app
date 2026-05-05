enum LoadStatus {
  pending,
  assigned,
  inTransit,
  delivered,
}

enum UserRole {
  shipper,
  driver,
}

extension LoadStatusX on LoadStatus {
  String get value {
    switch (this) {
      case LoadStatus.pending:
        return "pending";
      case LoadStatus.assigned:
        return "assigned";
      case LoadStatus.inTransit:
        return "in_transit";
      case LoadStatus.delivered:
        return "delivered";
    }
  }
}