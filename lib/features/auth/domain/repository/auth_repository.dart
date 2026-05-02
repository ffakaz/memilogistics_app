import 'package:dartz/dartz.dart';

import '../entities/auth_token.dart';
import '../entities/register_credentials.dart';
import '../entities/user_credentials.dart';
import '../failures/auth_failure.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, AuthToken>> login(UserCredentials credentials);

  Future<Either<AuthFailure, AuthToken>> register(
    RegisterCredentials credentials,
  );

  Future<Either<AuthFailure, void>> logout();

  Future<Either<AuthFailure, AuthToken?>> getSavedToken();

  Future<Either<AuthFailure, bool>> isLoggedIn();
}
