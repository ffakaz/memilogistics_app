import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:memilogistics_app/shared/http_exception.dart';
import 'auth_api_services.dart';

class FakeAuthApiService extends AuthApiService {
  FakeAuthApiService({
    required super.baseUrl,
    required super.client,
  });

  /// LOGIN - Fake response
  @override
  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Fake successful login
    if (body['email'] == 'test@example.com' && body['password'] == 'password') {
      return {
        'access_token': 'fake_access_token_123',
        'refresh_token': 'fake_refresh_token_456',
        'expiry': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      };
    } else {
      throw HttpException(
        message: 'Invalid credentials',
        statusCode: 401,
      );
    }
  }

  /// REGISTER - Fake response
  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Fake successful registration
    return {
      'access_token': 'fake_access_token_register_123',
      'refresh_token': 'fake_refresh_token_register_456',
      'expiry': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    };
  }

  /// LOGOUT - Fake response
  @override
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Fake successful logout - no response needed
  }

  /// Common headers
  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
    };
  }

  /// Response handler - not needed for fake, but keeping for consistency
  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      throw HttpException(
        message: decoded['message'] ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    }
  }
}