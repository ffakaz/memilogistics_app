
import '../entities/auth_token.dart';
import '../entities/user_credentials.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthToken> call(UserCredentials credentials) async {
    credentials.validate();
    final result = await repository.login(credentials);
    return result.fold(
      (failure) => throw failure,
      (token) => token,
    );
  }
}