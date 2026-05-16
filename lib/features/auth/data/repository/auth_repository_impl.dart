import 'package:dartz/dartz.dart';

import '../../domain/repository/auth_repository.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/register_credentials.dart';
import '../../domain/entities/user_credentials.dart';
import '../../domain/failures/auth_failure.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../services/auth_api_services.dart';
import '../storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
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
  } catch (e) {
    return Left(InvalidCredentialsFailure());
  }
}


  @override
  Future<Either<AuthFailure, AuthToken>> register(
    RegisterCredentials credentials,
  ) async {
    try {
      final request = RegisterRequestModel.fromEntity(credentials);
      final response = await apiService.register(request.toJson());
      final token = AuthResponseModel.fromJson(response).toEntity();

      await tokenStorage.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );

      return Right(token);
    } on Exception {
      return Left(InvalidCredentialsFailure());
    } catch (_) {
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
