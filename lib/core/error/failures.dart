// lib/core/error/failures.dart
//
// Domain-visible error types returned via Either<Failure, T>.
// The domain and presentation layers only ever see Failures, never exceptions.

import 'package:equatable/equatable.dart';

/// Base class — every repository method failure inherits from this.
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType(message: $message)';
}

// ── Network ────────────────────────────────────────────────────────────────

/// Non-2xx HTTP response from the server.
class ServerFailure extends Failure {
  const ServerFailure(
    super.message, {
    this.statusCode,
    this.errorCode,
  });

  final int? statusCode;
  final String? errorCode;

  @override
  List<Object?> get props => [message, statusCode, errorCode];
}

/// Device offline or DNS failure.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'No internet connection. Please check your network settings.',
  ]);
}

/// Request timed out.
class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The request timed out. Please try again.',
  ]);
}

// ── Auth ───────────────────────────────────────────────────────────────────

/// Wrong email or password (maps from 401 on login endpoint).
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([
    super.message = 'Invalid email or password.',
  ]);
}

/// User tried to register with an email that already exists.
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([
    super.message = 'An account with this email already exists.',
  ]);
}

/// Both tokens are dead; user must re-authenticate.
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([
    super.message = 'Your session has expired. Please log in again.',
  ]);
}

/// Forbidden (403).
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'You do not have permission to do that.',
  ]);
}

// ── Storage ────────────────────────────────────────────────────────────────

/// Secure-storage operation failed.
class StorageFailure extends Failure {
  const StorageFailure([
    super.message = 'A local storage error occurred.',
  ]);
}

/// Expected cache entry not found.
class CacheNotFoundFailure extends Failure {
  const CacheNotFoundFailure([
    super.message = 'Requested data was not found in local cache.',
  ]);
}

// ── Validation ─────────────────────────────────────────────────────────────

/// Client-side input did not pass validation before hitting the network.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// ── Parse ──────────────────────────────────────────────────────────────────

/// JSON parsing failed on the response body.
class ParseFailure extends Failure {
  const ParseFailure([
    super.message = 'Failed to parse the server response.',
  ]);
}

// ── Unknown ────────────────────────────────────────────────────────────────

/// Catch-all for completely unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}