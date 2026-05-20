abstract class AuthFailure {
  const AuthFailure();

  String get message;

  @override
  String toString() => message;
}

class InvalidCredentialsFailure extends AuthFailure {
  final String? customMessage;
  
  const InvalidCredentialsFailure({this.customMessage});

  @override
  String get message => customMessage ?? 'Invalid credentials';
}