import '../../domain/entities/user_credentials.dart';

class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel(this.email, this.password);

  factory LoginRequestModel.fromEntity(UserCredentials credentials) {
    return LoginRequestModel(credentials.email, credentials.password);
  }

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
      };
}