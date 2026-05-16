import '../../domain/entities/location.dart';
import '../models/location_model.dart';

class LocationMapper {
  const LocationMapper._();

  static LocationModel toModel(Location location) {
    return LocationModel(address: location.address);
  }
}
