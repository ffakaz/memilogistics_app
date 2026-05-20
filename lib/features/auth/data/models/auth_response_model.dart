import '../../domain/entities/auth_token.dart';

class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiry;
  final String? role; // User role: SHIPPER or CARRIER

  const AuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.expiry,
    this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final expiryValue = json['expiry'] as String?;

    return AuthResponseModel(
      accessToken: json['accessToken'] as String? ??
          json['access_token'] as String? ??
          '',
      refreshToken: json['refreshToken'] as String? ??
          json['refresh_token'] as String?,
      expiry: expiryValue == null ? null : DateTime.tryParse(expiryValue),
      role: json['role'] as String?, // Extract role from backend response
    );
  }

  factory AuthResponseModel.fromEntity(AuthToken token) {
    return AuthResponseModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiry: token.expiry,
      role: token.role,
    );
  }

  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiry: expiry,
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expiry': expiry?.toIso8601String(),
      'role': role,
    };
  }
}
