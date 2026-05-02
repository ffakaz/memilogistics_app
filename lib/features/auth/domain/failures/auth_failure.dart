abstract class AuthFailure {
  const AuthFailure();

  String get message;

  @override
  String toString() => message;
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure();

  @override
  String get message => 'Invalid credentials';
}