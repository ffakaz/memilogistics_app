import '../../domain/entities/location.dart';

class LocationModel {
  final String address;

  const LocationModel({
    required this.address,
  });

  factory LocationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LocationModel(
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
    };
  }

  factory LocationModel.fromEntity(
    Location entity,
  ) {
    return LocationModel(
      address: entity.address,
    );
  }
}