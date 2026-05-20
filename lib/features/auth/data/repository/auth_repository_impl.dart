import 'package:dartz/dartz.dart';

import '../../domain/repository/auth_repository.dart';
import '../../domain/entities/register_credentials.dart';
import '../../domain/entities/user_credentials.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/failures/auth_failure.dart';

import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../services/auth_api_service_real.dart';
import '../storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiServiceReal apiService;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.apiService,
    required this.tokenStorage,
  });

  @override
  Future<Either<AuthFailure, AuthToken>> login(
    UserCredentials credentials,
  ) async {
    try {
      final request = LoginRequestModel.fromEntity(credentials);
      final response = await apiService.login(request.toJson());
      final token = AuthResponseModel.fromJson(response).toEntity();

      await tokenStorage.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );

      return Right(token);
    } catch (_) {
      return Left(InvalidCredentialsFailure());
    }
  }

  @override
  Future<Either<AuthFailure, AuthToken>> register(
    RegisterCredentials credentials,
  ) async {
    try {
      final request = RegisterRequestModel.fromEntity(credentials);
      await apiService.register(request.toJson(), role: request.role.name.toUpperCase());

      // After successful registration backend requires login to obtain tokens
      final loginRequest = LoginRequestModel(request.email, request.password);
      final response = await apiService.login(loginRequest.toJson());
      final token = AuthResponseModel.fromJson(response).toEntity();

      await tokenStorage.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );

      return Right(token);
    } catch (_) {
      return Left(InvalidCredentialsFailure());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> logout() async {
    try {
      await apiService.logout({});
      await tokenStorage.clearTokens();
      return const Right(unit);
    } catch (_) {
      return Left(InvalidCredentialsFailure());
    }
  }

  @override
  Future<Either<AuthFailure, AuthToken?>> getSavedToken() async {
    try {
      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();

      if (accessToken != null) {
        return Right(
          AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        );
      }

      return const Right(null);
    } catch (_) {
      return Left(InvalidCredentialsFailure());
    }
  }

  @override
  Future<Either<AuthFailure, bool>> isLoggedIn() async {
    try {
      final token = await tokenStorage.getAccessToken();
      return Right(token != null);
    } catch (_) {
      return Left(InvalidCredentialsFailure());
    }
  }
}