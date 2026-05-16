enum ShipmentType {
  dryGoods('Dry Goods'),
  electronics('Electronics'),
  fuel('Fuel');

  const ShipmentType(this.displayName);

  final String displayName;
}
