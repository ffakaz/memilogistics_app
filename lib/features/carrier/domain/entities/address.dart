class Address {
  final int? id;
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String phoneNumber;

  const Address({
    this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.phoneNumber,
  });

  Address copyWith({
    int? id,
    String? street,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? phoneNumber,
  }) {
    return Address(
      id: id ?? this.id,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
