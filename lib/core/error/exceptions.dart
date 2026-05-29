/// Base exception type used across the app.
abstract class AppException implements Exception {
	const AppException([this.message = '']);

	final String message;

	@override
	String toString() => message.isEmpty ? 'AppException' : 'AppException: $message';
}

class NetworkException extends AppException {
	const NetworkException([super.message = 'Network error']);
}

class TimeoutException extends AppException {
	const TimeoutException([super.message = 'Request timed out']);
}

class RequestCancelledException extends AppException {
	const RequestCancelledException([super.message = 'Request cancelled']);
}

class MissingTokenException extends AppException {
	const MissingTokenException([super.message = 'Missing refresh token']);
}

class StorageException extends AppException {
	const StorageException([super.message = 'Storage error']);
}

class CacheNotFoundException extends AppException {
	const CacheNotFoundException([super.message = 'Cache not found']);
}

class UnauthorisedException extends AppException {
	UnauthorisedException([super.message = 'Unauthorised']);
}

class ForbiddenException extends AppException {
	ForbiddenException([super.message = 'Forbidden']);
}

class NotFoundException extends AppException {
	NotFoundException([super.message = 'Not found']);
}

class ConflictException extends AppException {
	ConflictException([super.message = 'Conflict']);
}

class ServerException extends AppException {
	ServerException([super.message = 'Server error']);
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
