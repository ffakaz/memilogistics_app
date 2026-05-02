

import '../repository/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    final result = await repository.logout();
    result.fold(
      (failure) => throw failure,
      (r) => null,
    );
  }
}