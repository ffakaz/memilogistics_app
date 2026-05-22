class ShipmentValidator {
  static String? validateShipperName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Shipper name is required';
    }

    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final parsed = double.tryParse(value);

    if (parsed == null || parsed <= 0) {
      return 'Invalid amount';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    return null;
  }
}
