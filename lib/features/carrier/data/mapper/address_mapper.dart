import '../../domain/entities/address.dart';
import '../models/address_model.dart';

class AddressMapper {
  const AddressMapper._();

  static AddressModel toModel(Address address) {
    return AddressModel(
      street: address.street,
      city: address.city,
      state: address.state,
      zip: address.zip,
      country: address.country,
      phoneNumber: address.phoneNumber,
    );
  }

  static Address toEntity(AddressModel model) {
    return Address(
      street: model.street,
      city: model.city,
      state: model.state,
      zip: model.zip,
      country: model.country,
      phoneNumber: model.phoneNumber,
    );
  }
}
