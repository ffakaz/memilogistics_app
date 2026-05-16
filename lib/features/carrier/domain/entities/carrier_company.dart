import 'address.dart';

class CarrierCompany {
  final String managerUserId;
  final String companyName;
  final String companyEmail;
  final Address address;

  const CarrierCompany({
    required this.managerUserId,
    required this.companyName,
    required this.companyEmail,
    required this.address,
  });
}
