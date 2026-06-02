// lib/core/network/dio_api_client.dart
//
// Real Dio-based implementation of ApiClient

import 'package:flutter/foundation.dart';
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
        // Treat only 2xx responses as valid. This ensures 401/403/etc
        // produce DioExceptions so the `AuthDioInterceptor.onError`
        // can catch them and run the refresh / session-expired logic.
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    // Configure platform-specific HTTP client adapter
    if (!kIsWeb) {
      // On mobile/desktop, Dio uses native HttpClientAdapter by default
      print('📱 [DioApiClient] Using default native HTTP adapter for mobile/desktop');
    } else {
      // On web, Dio automatically uses browser's fetch API via BrowserHttpClientAdapter
      // No need to explicitly set it - Dio handles this automatically
      print('🌐 [DioApiClient] Web platform detected - using browser HTTP adapter');
    }

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
    bool skipAuth = false,
  }) async {
    try {
      // Allow callers to pass a header flag `skipAuthInterceptor: 'true'`
      // as a lightweight way to avoid modifying the ApiClient interface.
      Map<String, String>? cleanedHeaders;
      var headerSkip = false;
      if (headers != null) {
        cleanedHeaders = Map<String, String>.from(headers);
        if (cleanedHeaders.remove('skipAuthInterceptor') != null) {
          headerSkip = true;
        }
      }

      final shouldSkip = skipAuth || headerSkip;
      final extra = shouldSkip ? {'skipAuthInterceptor': true} : null;

      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: cleanedHeaders ?? headers, extra: extra),
      );
      return _toApiResponse<T>(response);
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
    bool skipAuth = false,
  }) async {
    try {
      print('🌐 POST Request:');
      print('  Path: $path');
      print('  Query: $queryParameters');
      print('  Data: $data');
      print('  Headers: $headers');
      Map<String, String>? cleanedHeaders;
      var headerSkip = false;
      if (headers != null) {
        cleanedHeaders = Map<String, String>.from(headers);
        if (cleanedHeaders.remove('skipAuthInterceptor') != null) {
          headerSkip = true;
        }
      }

      final shouldSkip = skipAuth || headerSkip;
      final extra = shouldSkip ? {'skipAuthInterceptor': true} : null;

      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: cleanedHeaders ?? headers, extra: extra),
      );
      
      print('✅ POST Response:');
      print('  Status: ${response.statusCode}');
      print('  Data: ${response.data}');
      
      return _toApiResponse<T>(response);
    } on DioException catch (e) {
      print('❌ POST DioException:');
      print('  Type: ${e.type}');
      print('  Message: ${e.message}');
      print('  Response: ${e.response?.data}');
      print('  Status Code: ${e.response?.statusCode}');
      
      return _handleDioError<T>(e);
    } catch (e) {
      print('❌ POST Unknown Error:');
      print('  Error: $e');
      print('  Type: ${e.runtimeType}');
      
      return ApiResponse<T>.error('Unexpected error: $e', statusCode: 500);
    }
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    try {
      Map<String, String>? cleanedHeaders;
      var headerSkip = false;
      if (headers != null) {
        cleanedHeaders = Map<String, String>.from(headers);
        if (cleanedHeaders.remove('skipAuthInterceptor') != null) {
          headerSkip = true;
        }
      }

      final shouldSkip = skipAuth || headerSkip;
      final extra = shouldSkip ? {'skipAuthInterceptor': true} : null;
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: cleanedHeaders ?? headers, extra: extra),
      );
      return _toApiResponse<T>(response);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    }
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    try {
      Map<String, String>? cleanedHeaders;
      var headerSkip = false;
      if (headers != null) {
        cleanedHeaders = Map<String, String>.from(headers);
        if (cleanedHeaders.remove('skipAuthInterceptor') != null) {
          headerSkip = true;
        }
      }

      final shouldSkip = skipAuth || headerSkip;
      final extra = shouldSkip ? {'skipAuthInterceptor': true} : null;
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: cleanedHeaders ?? headers, extra: extra),
      );
      return _toApiResponse<T>(response);
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
    bool skipAuth = false,
  }) async {
    try {
      Map<String, String>? cleanedHeaders;
      var headerSkip = false;
      if (headers != null) {
        cleanedHeaders = Map<String, String>.from(headers);
        if (cleanedHeaders.remove('skipAuthInterceptor') != null) {
          headerSkip = true;
        }
      }

      final shouldSkip = skipAuth || headerSkip;
      final extra = shouldSkip ? {'skipAuthInterceptor': true} : null;
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: cleanedHeaders ?? headers, extra: extra),
      );
      return _toApiResponse<T>(response);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    final statusCode = error.response?.statusCode ?? 500;
    
    // Handle timeout errors specifically
    if (error.type == DioExceptionType.connectionTimeout) {
      return ApiResponse<T>.error(
        'Connection timeout: The server is taking too long to respond. '
        'This may be because the server is waking up from sleep (Render.com free tier). '
        'Please wait a moment and try again.',
        statusCode: 408, // Request Timeout
      );
    }
    
    if (error.type == DioExceptionType.receiveTimeout) {
      return ApiResponse<T>.error(
        'Receive timeout: The server took too long to send a response. '
        'Please check your internet connection and try again.',
        statusCode: 408, // Request Timeout
      );
    }
    
    if (error.type == DioExceptionType.sendTimeout) {
      return ApiResponse<T>.error(
        'Send timeout: Failed to send request to server. '
        'Please check your internet connection and try again.',
        statusCode: 408, // Request Timeout
      );
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return ApiResponse<T>.error(
        'Connection error: Unable to connect to server. '
        'Please check your internet connection and try again.',
        statusCode: 503, // Service Unavailable
      );
    }
    
    final message = _messageFromBody(error.response?.data) ??
        error.message ??
        'Unknown error occurred';
    
    return ApiResponse<T>.error(message, statusCode: statusCode);
  }

  ApiResponse<T> _toApiResponse<T>(Response<T> response) {
    final statusCode = response.statusCode ?? 200;
    if (statusCode >= 400) {
      return ApiResponse<T>.error(
        _messageFromBody(response.data) ?? 'Request failed',
        statusCode: statusCode,
      );
    }
    return ApiResponse.success(response.data as T, statusCode: statusCode);
  }

  String? _messageFromBody(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}
