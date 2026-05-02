import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:memilogistics_app/shared/http_exception.dart';

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
  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
    };
  }

  /// Response handler
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