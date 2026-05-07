import 'package:http/http.dart' as http;

abstract class AuthApiService {
  final String baseUrl;
  final http.Client client;

  AuthApiService({
    required this.baseUrl,
    required this.client,
  });

  /// LOGIN
  Future<Map<String, dynamic>> login(Map<String, dynamic> body);

  /// REGISTER
  Future<Map<String, dynamic>> register(Map<String, dynamic> body);

  /// LOGOUT
  Future<void> logout();

  /// Common headers
  /// Response handler
  // Helper methods removed: not referenced in the codebase.
}