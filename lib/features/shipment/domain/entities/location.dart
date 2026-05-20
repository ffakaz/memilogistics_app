class Location {
  final String address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  const Location({
    required this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  // Convenience getters for display
  String get shortLabel {
    if (city != null && state != null) {
      return '$city, $state';
    } else if (city != null) {
      return city!;
    } else if (state != null) {
      return state!;
    }
    return address;
  }

  String get fullLabel {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}
