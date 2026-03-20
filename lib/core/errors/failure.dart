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
    String message = 'Authentication failed',
  }) : super(message: message);
}

/// Authorization-related failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    String message = 'You do not have permission to perform this action',
  }) : super(message: message);
}

/// Validation-related failures (form input, data validation)
class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = 'Validation failed',
  }) : super(message: message);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Network error. Please check your internet connection.',
  }) : super(message: message);
}

/// Server/Firestore-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Server error. Please try again later.',
  }) : super(message: message);
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Cache error. Please try again.',
  }) : super(message: message);
}

/// Generic failures
class GenericFailure extends Failure {
  const GenericFailure({
    String message = 'An unexpected error occurred',
  }) : super(message: message);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'The requested resource was not found',
  }) : super(message: message);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Operation timed out. Please try again.',
  }) : super(message: message);
}
