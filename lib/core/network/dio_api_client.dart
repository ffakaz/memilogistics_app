// lib/core/network/dio_api_client.dart
//
// Real Dio-based implementation of ApiClient

import 'package:dio/dio.dart';
import 'package:memilogistics_app/core/core.dart';

class DioApiClient implements ApiClient {
  final Dio _dio;

  DioApiClient._({required Dio dio}) : _dio = dio;

  /// Create the configured [Dio] instance.
  ///
  /// [onSessionExpired] is called by [AuthDioInterceptor] when the refresh
  /// cycle fails. Wire this to your router to navigate to the login screen.
  static DioApiClient create({
    required SecureStorageService storageService,
    required void Function() onSessionExpired,
  }) {
    final config = ApiConfig.current;

    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Treat everything below 500 as a valid response for the interceptor
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.addAll([
      // 1. JWT attach + 401 refresh + retry
      AuthDioInterceptor(
        dio: dio,
        storage: storageService,
        onSessionExpired: onSessionExpired,
      ),
      // 2. Request/response logging (disabled in production)
      if (config.enableLogging)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false, // don't log auth headers in dev
          responseHeader: false,
          error: true,
          logPrint: (o) => _log(o.toString()),
        ),
    ]);

    return DioApiClient._(dio: dio);
  }

  static void _log(String msg) {
    // Replace with your preferred logger (e.g. `logger` package)
    // ignore: avoid_print
    print('[DioApiClient] $msg');
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiResponse.success(response.data as T, statusCode: response.statusCode ?? 200);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiResponse.success(response.data as T, statusCode: response.statusCode ?? 200);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiResponse.success(response.data as T, statusCode: response.statusCode ?? 200);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiResponse.success(response.data as T, statusCode: response.statusCode ?? 200);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    final statusCode = error.response?.statusCode ?? 500;
    final message = error.response?.data?['message'] ?? error.message ?? 'Unknown error occurred';
    
    return ApiResponse<T>.error(message, statusCode: statusCode);
  }
}