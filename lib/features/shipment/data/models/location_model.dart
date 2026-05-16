class LocationModel {
  final String address;

  const LocationModel({required this.address});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(address: json['address'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'address': address};
  }
}
