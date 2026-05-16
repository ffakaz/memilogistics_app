class AuthToken {

  final String accessToken;

  final String? refreshToken;

  final DateTime? expiry;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.expiry,
  });

  bool get hasAccessToken => accessToken.isNotEmpty;

  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;
}