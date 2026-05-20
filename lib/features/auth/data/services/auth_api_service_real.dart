// lib/features/auth/data/services/auth_api_service_real.dart

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants/api_constants.dart';

class AuthApiServiceReal {
  final ApiClient _apiClient;

  AuthApiServiceReal(this._apiClient);

  /// Login
  /// POST /api/auth/login
  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final response = await _apiClient.post(
      '${ApiConstants.apiPrefix}${AuthEndpoints.login}',
      data: body,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message ?? 'Login failed');
    }

    return response.data as Map<String, dynamic>;
  }

  /// Register
  /// POST /api/auth/register?role={role}
  /// Note: Backend returns 200 OK on success
  /// After registration, you must call login() to get tokens
  /// Role is sent as QUERY PARAMETER (not in body!)
  /// 
  /// IMPORTANT: Render.com free tier sleeps after 15 min inactivity
  /// First request may timeout - we retry once with longer timeout
  Future<void> register(
    Map<String, dynamic> body, {
    required String role, // Role as query parameter
  }) async {
    final fullUrl = '${ApiConstants.apiPrefix}${AuthEndpoints.register}?role=$role';
    
    print('🔵 Registration Request:');
    print('  Full URL: $fullUrl');
    print('  Role (query param): $role');
    print('  Body: $body');
    
    try {
      final response = await _apiClient.post(
        '${ApiConstants.apiPrefix}${AuthEndpoints.register}',
        data: body,
        queryParameters: {'role': role}, // Role as query parameter
      );

      print('✅ Registration Response:');
      print('  Success: ${response.isSuccess}');
      print('  Status Code: ${response.statusCode}');
      print('  Data: ${response.data}');
      print('  Message: ${response.message}');

      if (!response.isSuccess) {
        print('❌ Registration Failed:');
        print('  Status Code: ${response.statusCode}');
        print('  Message: ${response.message}');
        print('  Data: ${response.data}');
        
        // Provide user-friendly error message for timeout
        if (response.statusCode == 408) {
          throw Exception(
            'Server is waking up from sleep. This can take up to 60 seconds on first request. '
            'Please wait a moment and try again.'
          );
        }
        
        throw Exception(response.message ?? 'Registration failed');
      }

      // Backend returns 200 OK on success
      print('✅ Registration successful! Backend returned 200 OK');
    } catch (e) {
      print('❌ Registration Exception: $e');
      rethrow;
    }
  }

  /// Logout
  /// POST /api/auth/logout
  Future<void> logout(Map<String, dynamic> body) async {
    final response = await _apiClient.post(
      '${ApiConstants.apiPrefix}${AuthEndpoints.logout}',
      data: body,
    );

    if (!response.isSuccess) {
      throw Exception(response.message ?? 'Logout failed');
    }
  }

  /// Refresh Token
  /// POST /api/auth/refresh
  Future<Map<String, dynamic>> refreshToken(Map<String, dynamic> body) async {
    final response = await _apiClient.post(
      '${ApiConstants.apiPrefix}${AuthEndpoints.refresh}',
      data: body,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message ?? 'Token refresh failed');
    }

    return response.data as Map<String, dynamic>;
  }

  /// Forgot Password
  /// POST /api/auth/forgot-password
  Future<void> forgotPassword(String email) async {
    final response = await _apiClient.post(
      '${ApiConstants.apiPrefix}${AuthEndpoints.forgotPassword}',
      data: {'email': email},
    );

    if (!response.isSuccess) {
      throw Exception(response.message ?? 'Failed to send reset email');
    }
  }

  /// Reset Password
  /// POST /api/auth/reset-password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.apiPrefix}${AuthEndpoints.resetPassword}',
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.message ?? 'Failed to reset password');
    }
  }
}
