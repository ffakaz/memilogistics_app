import '../../domain/entities/register_credentials.dart';

class RegisterRequestModel {
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  factory RegisterRequestModel.fromEntity(RegisterCredentials credentials) {
    return RegisterRequestModel(
      email: credentials.email,
      password: credentials.password,
      confirmPassword: credentials.confirmPassword,
    );
  }

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      email: _readString(json, 'email'),
      password: _readString(json, 'password'),
      confirmPassword: _readString(
        json,
        'password_confirmation',
        fallbackKey: 'confirmPassword',
      ),
    );
  }

  RegisterCredentials toEntity() {
    return RegisterCredentials(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
    };
  }

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    String? fallbackKey,
  }) {
    final value = json[key] ?? (fallbackKey == null ? null : json[fallbackKey]);
    return value is String ? value : '';
  }
}
