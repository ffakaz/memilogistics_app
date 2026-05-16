import '../../domain/entities/auth_token.dart';

class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiry;

  const AuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.expiry,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final expiryValue = json['expiry'] as String?;

    return AuthResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
      expiry: expiryValue == null ? null : DateTime.tryParse(expiryValue),
    );
  }

  factory AuthResponseModel.fromEntity(AuthToken token) {
    return AuthResponseModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiry: token.expiry,
    );
  }

  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiry: expiry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expiry': expiry?.toIso8601String(),
    };
  }
}