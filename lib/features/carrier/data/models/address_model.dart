class AddressModel {
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String phoneNumber;

  const AddressModel({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.phoneNumber,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zip: (json['zip'] ?? json['postalCode']) as String? ?? '',
      country: json['country'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'phoneNumber': phoneNumber,
    };
  }
}
