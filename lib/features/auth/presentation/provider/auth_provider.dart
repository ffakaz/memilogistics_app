import 'package:flutter/material.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/is_logged_in_usecase.dart';
import '../../domain/usecases/get_current_token_usecase.dart';
import '../../domain/entities/register_credentials.dart';
import '../../domain/entities/user_credentials.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;
  final GetCurrentTokenUseCase getCurrentTokenUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.isLoggedInUseCase,
    required this.getCurrentTokenUseCase,
  });

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  String? _currentToken;
  bool _initialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentToken => _currentToken;
  bool get initialized => _initialized;
  bool get isAuthenticated => _isLoggedIn; // Alias
  String? get error => _errorMessage; // Alias

  Future<void> init() async {
    _isLoggedIn = await isLoggedInUseCase.call();
    if (_isLoggedIn) {
      final token = await getCurrentTokenUseCase.call();
      _currentToken = token?.accessToken;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = UserCredentials(email: email, password: password);
      final token = await loginUseCase.call(credentials);
      _currentToken = token.accessToken;
      _isLoggedIn = true;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
    return _isLoggedIn;
  }

  Future<bool> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = RegisterCredentials(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      final token = await registerUseCase.call(credentials);
      _currentToken = token.accessToken;
      _isLoggedIn = true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
    return _isLoggedIn;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await logoutUseCase.call();
      _isLoggedIn = false;
      _currentToken = null;
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
