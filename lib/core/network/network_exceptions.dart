// lib/core/network/network_exceptions.dart
//
// Converts raw DioExceptions into typed AppExceptions.
// Called in every data-source catch block — never used directly by the domain.

import 'package:dio/dio.dart';
import 'package:memilogistics_app/core/error/exceptions.dart';

class NetworkExceptionMapper {
  NetworkExceptionMapper._();

  /// Convert a [DioException] into the closest typed [AppException].
  static AppException from(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.cancel:
        return const RequestCancelledException();

      case DioExceptionType.badResponse:
        return _fromBadResponse(e);

      case DioExceptionType.unknown:
      default:
        final msg = e.message ?? '';
        if (msg.toLowerCase().contains('socket') ||
            msg.toLowerCase().contains('connection')) {
          return const NetworkException();
        }
        return HttpException(
          message: msg.isEmpty ? 'An unexpected error occurred.' : msg,
          statusCode: e.response?.statusCode ?? 0,
        );
    }
  }

  static AppException _fromBadResponse(DioException e) {
    final code = e.response?.statusCode ?? 0;
    final body = e.response?.data;
    final message = _msg(body);
    final errorCode = _errorCode(body);

    switch (code) {
      case 400:
        return HttpException(
            message: message, statusCode: 400, errorCode: errorCode);
      case 401:
        return UnauthorisedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return HttpException(
          message: message.isEmpty ? 'Resource not found.' : message,
          statusCode: 404,
          errorCode: errorCode,
        );
      case 409:
        return HttpException(
            message: message, statusCode: 409, errorCode: errorCode);
      case 422:
        return HttpException(
            message: message, statusCode: 422, errorCode: errorCode);
      case 429:
        return const HttpException(
            message: 'Too many requests. Please slow down.', statusCode: 429);
      case 500:
      case 502:
      case 503:
        return HttpException(
            message: 'Server error. Please try again later.',
            statusCode: code);
      default:
        return HttpException(
          message: message.isEmpty ? 'HTTP error $code.' : message,
          statusCode: code,
          errorCode: errorCode,
        );
    }
  }

  static String _msg(dynamic body) {
    if (body is Map<String, dynamic>) {
      return (body['message'] ??
              body['error'] ??
              body['detail'] ??
              body['title'] ??
              '')
          .toString();
    }
    if (body is String && body.isNotEmpty) return body;
    return '';
  }

  static String? _errorCode(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['errorCode']?.toString() ?? body['code']?.toString();
    }
    return null;
  }
}