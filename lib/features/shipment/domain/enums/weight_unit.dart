enum WeightUnit {
  kg,
  lbs,
  ton;

  String get displayName {
    switch (this) {
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.lbs:
        return 'lbs';
      case WeightUnit.ton:
        return 'tons';
    }
  }
}
