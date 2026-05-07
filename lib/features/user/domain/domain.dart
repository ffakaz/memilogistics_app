// lib/features/user/domain/domain.dart
//
// Barrel export file for user domain layer

// Entities
export 'entities/current_user.dart';
export 'entities/user_profile.dart';
export 'entities/user_permission.dart';

// Enums
export 'enums/app_role.dart';
export 'enums/account_status.dart';

// Repositories
export 'repositories/user_repository.dart';

// Use Cases
export 'usecases/get_current_user_usecase.dart';
export 'usecases/update_profile_usecase.dart';
export 'usecases/get_permissions_usecase.dart';
