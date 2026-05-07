// lib/features/user/domain/usecases/get_current_user_usecase.dart

import '../entities/current_user.dart';
import '../repositories/user_repository.dart';

class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<CurrentUser> call() async {
    return await repository.getCurrentUser();
  }
}
