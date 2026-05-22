import '../../domain/entities/location.dart';

import '../models/location_model.dart';

class LocationMapper {
  static Location toEntity(LocationModel model) {
    return Location(address: model.address);
  }

  static LocationModel toModel(Location entity) {
    return LocationModel(address: entity.address);
  }
}
