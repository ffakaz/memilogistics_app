class AuthToken {

  final String accessToken;

  final String? refreshToken;

  final DateTime? expiry;

  final String? role; // User role: SHIPPER or CARRIER

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.expiry,
    this.role,
  });

  bool get hasAccessToken => accessToken.isNotEmpty;

  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;
}