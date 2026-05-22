import 'address.dart';

class CarrierCompany {
  final int id;
  final String companyName;
  final Address address;
  final String companyEmail;

  const CarrierCompany({
    required this.id,
    required this.companyName,
    required this.address,
    required this.companyEmail,
  });

  CarrierCompany copyWith({
    int? id,
    String? companyName,
    Address? address,
    String? companyEmail,
  }) {
    return CarrierCompany(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      companyEmail: companyEmail ?? this.companyEmail,
    );
  }
}
