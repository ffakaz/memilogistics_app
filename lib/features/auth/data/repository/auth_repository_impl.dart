import 'package:dartz/dartz.dart';

import '../../domain/repository/auth_repository.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/register_credentials.dart';
import '../../domain/entities/user_credentials.dart';
import '../../domain/failures/auth_failure.dart';
import '../services/auth_api_services.dart';
import '../storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({required this.apiService, required this.tokenStorage});

  @override
  Future<Either<AuthFailure, AuthToken>> login(
    UserCredentials credentials,
  ) async {
    try {
      final response = await apiService.login({
        'email': credentials.email,
        'password': credentials.password,
      });

      final token = AuthToken(
        accessToken: response['access_token'],
        refreshToken: response['refresh_token'],
        expiry: response['expiry'] != null
            ? DateTime.parse(response['expiry'])
            : null,
      );

      await tokenStorage.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );

      return Right(token);
    } catch (e) {
      return Left(InvalidCredentialsFailure());
    }
  }

  @override
  Future<Either<AuthFailure, AuthToken>> register(
    RegisterCredentials credentials,
  ) async {
    try {
      final response = await apiService.register({
        'email': credentials.email,
        'password': credentials.password,
        'password_confirmation': credentials.confirmPassword,
      });

      final token = AuthToken(
        accessToken: response['access_token'],
        refreshToken: response['refresh_token'],
        expiry: response['expiry'] != null
            ? DateTime.parse(response['expiry'])
            : null,
      );

      await tokenStorage.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );

      return Right(token);
    } catch (e) {
      return Left(InvalidCredentialsFailure());
    }
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    try {
      await apiService.logout();
      await tokenStorage.clearTokens();
      return const Right(null);
    } catch (e) {
      return Left(InvalidCredentialsFailure());
    }
  }

  @override
  Future<Either<AuthFailure, AuthToken?>> getSavedToken() async {
    try {
      final token = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();

      if (token != null) {
        return Right(AuthToken(accessToken: token, refreshToken: refreshToken));
      } else {
        return const Right(null);
      }
    } catch (e) {
      return Left(InvalidCredentialsFailure());
    }
  }

  @override
  Future<Either<AuthFailure, bool>> isLoggedIn() async {
    try {
      final token = await tokenStorage.getAccessToken();
      return Right(token != null);
    } catch (e) {
      return Left(InvalidCredentialsFailure());
    }
  }
}
