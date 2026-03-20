// lib/core/utils/result.dart
import 'package:equatable/equatable.dart';
import '../errors/failure.dart';

/// Result wrapper for Either pattern (success or failure)
abstract class Result<T> extends Equatable {
  const Result();

  /// Fold the result into two paths: success or failure
  O fold<O>(
    O Function(AppFailure failure) onFailure,
    O Function(T data) onSuccess,
  );

  /// Get the success value or null
  T? getOrNull();

  /// Get the failure or null
  AppFailure? failureOrNull();

  /// Check if result is success
  bool isSuccess();

  /// Check if result is failure
  bool isFailure();
}

/// Success result
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  O fold<O>(
    O Function(AppFailure failure) onFailure,
    O Function(T data) onSuccess,
  ) {
    return onSuccess(data);
  }

  @override
  T? getOrNull() => data;

  @override
  AppFailure? failureOrNull() => null;

  @override
  bool isSuccess() => true;

  @override
  bool isFailure() => false;

  @override
  List<Object?> get props => [data];
}

/// Failure result
class FailureResult<T> extends Result<T> {
  final AppFailure failure;

  const FailureResult(this.failure);

  @override
  O fold<O>(
    O Function(AppFailure failure) onFailure,
    O Function(T data) onSuccess,
  ) {
    return onFailure(failure);
  }

  @override
  T? getOrNull() => null;

  @override
  AppFailure? failureOrNull() => failure;

  @override
  bool isSuccess() => false;

  @override
  bool isFailure() => true;

  @override
  List<Object?> get props => [failure];
}

// Alias for Failure to avoid collision with Result<T>
typedef AppFailure = Failure;
