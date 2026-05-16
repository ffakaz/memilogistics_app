// lib/features/auth/data/services/fake_auth_api_service_adapter.dart
//
// Adapter that connects your existing AuthApiService interface to the new ApiClient

import 'package:http/http.dart' as http;
import 'package:memilogistics_app/core/network/api_client.dart';
import 'package:memilogistics_app/features/auth/data/services/auth_api_services.dart';

class FakeAuthApiServiceAdapter extends AuthApiService {
  final ApiClient _apiClient;

  FakeAuthApiServiceAdapter({required ApiClient apiClient})
    : _apiClient = apiClient,
      super(
        baseUrl: 'http://localhost', // Not used with fake API
        client: http.Client(), // Not used with fake API
      );

  @override
  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: body,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Login failed');
    }
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: body,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Registration failed');
    }
  }

  @override
  Future<void> logout() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/logout',
    );

    if (!response.isSuccess) {
      throw Exception(response.message ?? 'Logout failed');
    }
  }
}
