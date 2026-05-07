/// Operation State - Base classes for state management
///
/// These base states are used for operations (sign in, sign up, etc.)
/// and can be reused across different features.
library;

/// Base state for operations
abstract class OperationState {
  const OperationState();

  /// Optional message for the state (e.g., error message)
  String? get message => null;
}


/// Initial state - nothing has been performed yet
class OperationInitial extends OperationState {
  const OperationInitial();
}

/// Loading state - processing
class OperationLoading extends OperationState {
  const OperationLoading();
}

/// Success state - completed successfully
/// Generic type T allows carrying data if necessary
class OperationSuccess<T> extends OperationState {
  const OperationSuccess([this.data]);

  /// Data returned from operation (if any)
  final T? data;
}

/// Error state - error occurred
/// Contains exception information for error handling
abstract class OperationError extends OperationState {
  const OperationError();

  /// Get error message
  @override
  String get message;
}

/// Simple implementation of OperationError for general use
class OperationFailure extends OperationError {
  final String errorMessage;
  const OperationFailure(this.errorMessage);

  @override
  String get message => errorMessage;
}
