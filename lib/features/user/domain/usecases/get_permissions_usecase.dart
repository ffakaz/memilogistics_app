// lib/features/user/domain/usecases/get_permissions_usecase.dart

import '../entities/user_permission.dart';
import '../repositories/user_repository.dart';

class GetPermissionsUseCase {
  final UserRepository repository;

  GetPermissionsUseCase(this.repository);

  Future<List<UserPermission>> call(String userId) async {
    return await repository.getPermissions(userId);
  }
}
