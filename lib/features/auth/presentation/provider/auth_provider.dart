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
  String? _userRole; // User role: SHIPPER or CARRIER
  bool _initialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentToken => _currentToken;
  String? get userRole => _userRole; // Expose user role
  bool get initialized => _initialized;
  bool get isAuthenticated => _isLoggedIn; // Alias
  String? get error => _errorMessage; // Alias

  Future<void> init() async {
    _isLoggedIn = await isLoggedInUseCase.call();
    if (_isLoggedIn) {
      final token = await getCurrentTokenUseCase.call();
      _currentToken = token?.accessToken;
      _userRole = token?.role; // Load user role
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
      _userRole = token.role; // Store user role
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
    String confirmPassword, {
    required String role, // Added: User role (shipper/carrier)
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📱 AuthProvider: Starting registration');
      print('  Email: $email');
      print('  Role: $role');
      
      final credentials = RegisterCredentials(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      );
      
      print('📱 AuthProvider: Calling registerUseCase');
      final token = await registerUseCase.call(credentials);
      
      print('📱 AuthProvider: Registration successful');
      print('  Access Token: ${token.accessToken.substring(0, 20)}...');
      print('  Role: ${token.role}');
      
      _currentToken = token.accessToken;
      _userRole = token.role; // Store user role
      _isLoggedIn = true;
    } catch (e) {
      print('📱 AuthProvider: Registration failed');
      print('  Error: $e');
      print('  Error Type: ${e.runtimeType}');
      
      _errorMessage = 'Registration failed: ${e.toString().replaceAll('Exception: ', '')}';
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
      _userRole = null; // Clear user role
    } catch (e) {
      // Backend logout endpoint has a bug (returns 400 with null parameter error)
      // But local logout still works, so we clear the session anyway
      print('⚠️ Backend logout error (ignoring): $e');
      _isLoggedIn = false;
      _currentToken = null;
      _userRole = null;
      // Don't set error message since logout functionally works
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
