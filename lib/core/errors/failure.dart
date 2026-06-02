// lib/core/errors/failure.dart
import 'package:equatable/equatable.dart';

/// Base class for all failures/errors
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Authentication-related failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed',
  });
}

/// Authorization-related failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'You do not have permission to perform this action',
  });
}

/// Validation-related failures (form input, data validation)
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation failed',
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network error. Please check your internet connection.',
  });
}

/// Server/Firestore-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error. Please try again later.',
  });
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error. Please try again.',
  });
}

/// Generic failures
class GenericFailure extends Failure {
  const GenericFailure({
    super.message = 'An unexpected error occurred',
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found',
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Operation timed out. Please try again.',
  });
}
