
import '../entities/auth_token.dart';
import '../entities/register_credentials.dart';
import '../repository/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthToken> call(RegisterCredentials credentials) async {
    final validation = credentials.validate();
    if (!validation.isValid) {
      throw Exception(validation.message);
    }

    final result = await repository.register(credentials);
    return result.fold((failure) => throw failure, (token) => token);
  }
}
