class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiry;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.expiry,
  });
}