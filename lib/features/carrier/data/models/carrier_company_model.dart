import 'address_model.dart';

class CarrierCompanyModel {
  final String managerUserId;
  final String companyName;
  final String companyEmail;
  final AddressModel address;

  const CarrierCompanyModel({
    required this.managerUserId,
    required this.companyName,
    required this.companyEmail,
    required this.address,
  });

  factory CarrierCompanyModel.fromJson(Map<String, dynamic> json) {
    return CarrierCompanyModel(
      managerUserId: json['managerUserId'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      companyEmail: json['companyEmail'] as String? ?? '',
      address: AddressModel.fromJson(
        json['address'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'managerUserId': managerUserId,
      'companyName': companyName,
      'companyEmail': companyEmail,
      'address': address.toJson(),
    };
  }
}
