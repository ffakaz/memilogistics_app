enum ShipmentType {
  dryGoods,
  electronics,
  fuel,
  fullTruckLoad,
  lessThanTruckLoad,
  partialTruckLoad;

  String get displayName {
    switch (this) {
      case ShipmentType.dryGoods:
        return 'Dry Goods';
      case ShipmentType.electronics:
        return 'Electronics';
      case ShipmentType.fuel:
        return 'Fuel';
      case ShipmentType.fullTruckLoad:
        return 'Full Truck Load (FTL)';
      case ShipmentType.lessThanTruckLoad:
        return 'Less Than Truck Load (LTL)';
      case ShipmentType.partialTruckLoad:
        return 'Partial Truck Load (PTL)';
    }
  }
}
