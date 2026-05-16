import '../../domain/entities/user_credentials.dart';

class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({required this.email, required this.password});

  factory LoginRequestModel.fromEntity(UserCredentials credentials) {
    return LoginRequestModel(
      email: credentials.email,
      password: credentials.password,
    );
  }

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      email: _readString(json, 'email'),
      password: _readString(json, 'password'),
    );
  }

  UserCredentials toEntity() {
    return UserCredentials(email: email, password: password);
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String ? value : '';
  }
}
