// lib/features/user/domain/usecases/update_profile_usecase.dart

import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UserProfile> call({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    // Validate updates
    if (updates.isEmpty) {
      throw Exception('No updates provided');
    }

    return await repository.updateProfile(
      userId: userId,
      updates: updates,
    );
  }
}
