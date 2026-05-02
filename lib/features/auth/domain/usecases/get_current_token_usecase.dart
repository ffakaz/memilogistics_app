

import '../repository/auth_repository.dart';
import '../entities/auth_token.dart';

class GetCurrentTokenUseCase {
  final AuthRepository repository;

  GetCurrentTokenUseCase(this.repository);

  Future<AuthToken?> call() async {
    final result = await repository.getSavedToken();
    return result.fold(
      (failure) => null,
      (token) => token,
    );
  }
}