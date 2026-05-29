// lib/core/error/http_error_mapper.dart

import 'exceptions.dart';

class HttpErrorMapper {
  HttpErrorMapper._();

  static AppException map(int statusCode, String? message) {
    final msg = message ?? 'HTTP $statusCode error';
    if (statusCode == 401) return UnauthorisedException(msg);
    if (statusCode == 403) return ForbiddenException(msg);
    if (statusCode == 404) return NotFoundException(msg);
    if (statusCode == 409) return ConflictException(msg);
    if (statusCode >= 500) return ServerException(msg);
    if (statusCode >= 400) return HttpException(message: msg, statusCode: statusCode);
    return HttpException(message: msg, statusCode: statusCode);
  }
}
