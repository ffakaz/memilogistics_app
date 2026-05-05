/// Base exception type used across the app.
abstract class AppException implements Exception {
	const AppException([this.message = '']);

	final String message;

	@override
	String toString() => message.isEmpty ? 'AppException' : 'AppException: $message';
}

class NetworkException extends AppException {
	const NetworkException([String message = 'Network error']) : super(message);
}

class TimeoutException extends AppException {
	const TimeoutException([String message = 'Request timed out']) : super(message);
}

class RequestCancelledException extends AppException {
	const RequestCancelledException([String message = 'Request cancelled']) : super(message);
}

class MissingTokenException extends AppException {
	const MissingTokenException([String message = 'Missing refresh token']) : super(message);
}

class StorageException extends AppException {
	const StorageException([String message = 'Storage error']) : super(message);
}

class CacheNotFoundException extends AppException {
	const CacheNotFoundException([String message = 'Cache not found']) : super(message);
}

class UnauthorisedException extends AppException {
	UnauthorisedException([String message = 'Unauthorised']) : super(message);
}

class ForbiddenException extends AppException {
	ForbiddenException([String message = 'Forbidden']) : super(message);
}

class HttpException extends AppException {
	const HttpException({
		String message = 'HTTP error',
		this.statusCode = 0,
		this.errorCode,
	}) : super(message);

	final int statusCode;
	final String? errorCode;

	@override
	String toString() => 'HttpException(statusCode: $statusCode, message: $message, errorCode: $errorCode)';
}
