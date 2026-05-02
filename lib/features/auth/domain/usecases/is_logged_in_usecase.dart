

import '../repository/auth_repository.dart';

class IsLoggedInUseCase {
  final AuthRepository repository;

  IsLoggedInUseCase(this.repository);

  Future<bool> call() async {
    final result = await repository.isLoggedIn();
    return result.fold(
      (failure) => false,
      (isLoggedIn) => isLoggedIn,
    );
  }
}