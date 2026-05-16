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

  String get shortLabel {
    final parts = [
      city,
      state,
    ].whereType<String>().where((part) => part.trim().isNotEmpty);

    return parts.isEmpty ? address : parts.join(', ');
  }

  String get fullLabel {
    final locality = [
      city,
      state,
      zipCode,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');

    final parts = [
      address,
      locality,
      country,
    ].whereType<String>().where((part) => part.trim().isNotEmpty);

    return parts.join(', ');
  }
}
