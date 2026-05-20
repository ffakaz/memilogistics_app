import '../../../user/domain/enums/app_role.dart';
import '../../domain/entities/register_credentials.dart';

class RegisterRequestModel {

  final String email;

  final String password;

  final AppRole role;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': _mapRole(role),
    };
  }

  String _mapRole(AppRole role) {
    switch (role) {

      case AppRole.shipper:
        return 'SHIPPER';

      case AppRole.carrier:
        return 'CARRIER';

      case AppRole.admin:
        return 'ADMIN';
    }
  }

  RegisterRequestModel copyWith({
    String? email,
    String? password,
    AppRole? role,
  }) {
    return RegisterRequestModel(
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  factory RegisterRequestModel.fromEntity(RegisterCredentials credentials) {
    final roleStr = credentials.role.toLowerCase();
    AppRole role;

    if (roleStr == 'shipper') {
      role = AppRole.shipper;
    } else if (roleStr == 'carrier') {
      role = AppRole.carrier;
    } else if (roleStr == 'admin') {
      role = AppRole.admin;
    } else {
      role = AppRole.shipper;
    }

    return RegisterRequestModel(
      email: credentials.email,
      password: credentials.password,
      role: role,
    );
  }
}