// lib/core/network/api_client.dart
//
// Abstract interface for API clients. This allows us to swap between
// real Dio-based implementation and fake implementations for testing.

abstract class ApiClient {
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}

class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final String? message;
  final bool isSuccess;

  const ApiResponse({
    this.data,
    required this.statusCode,
    this.message,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data, {int statusCode = 200}) {
    return ApiResponse<T>(
      data: data,
      statusCode: statusCode,
      isSuccess: true,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse<T>(
      statusCode: statusCode,
      message: message,
      isSuccess: false,
    );
  }
}
