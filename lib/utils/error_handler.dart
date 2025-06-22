import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import 'constants.dart';

// Custom Exception Classes
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.originalError});
}

class StorageException extends AppException {
  StorageException(super.message, {super.code, super.originalError});
}

class LessonException extends AppException {
  LessonException(super.message, {super.code, super.originalError});
}

class ProgressException extends AppException {
  ProgressException(super.message, {super.code, super.originalError});
}

// Error Handler Class
class ErrorHandler {
  static void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    BuildContext? context,
    bool showSnackbar = true,
    bool logError = true,
  }) {
    // Log error for debugging
    if (logError) {
      _logError(error, stackTrace);
    }

    // Show user-friendly message
    if (context != null && showSnackbar) {
      final message = _getUserFriendlyMessage(error);
      CustomSnackbar.show(context, message: message, type: SnackbarType.error);
    }
  }

  static void _logError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('🚨 Error occurred: $error');
      if (stackTrace != null) {
        print('📍 Stack trace: $stackTrace');
      }
    }

    // In production, you might want to send this to a crash reporting service
    // like Firebase Crashlytics or Sentry
    _reportToAnalytics(error, stackTrace);
  }

  static void _reportToAnalytics(dynamic error, StackTrace? stackTrace) {
    // Implement crash reporting here
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);

    if (kDebugMode) {
      print('📊 Error reported to analytics: ${error.runtimeType}');
    }
  }

  static String _getUserFriendlyMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    switch (error.runtimeType.toString()) {
      case 'SocketException':
      case 'TimeoutException':
      case 'HttpException':
        return AppConstants.errorMessages['network_error']!;

      case 'FormatException':
      case 'TypeError':
        return AppConstants.errorMessages['validation_error']!;

      case 'FileSystemException':
        return AppConstants.errorMessages['file_not_found']!;

      case 'PlatformException':
        return AppConstants.errorMessages['permission_denied']!;

      default:
        return AppConstants.errorMessages['unknown_error']!;
    }
  }

  // Specific error handlers for different scenarios
  static void handleNetworkError(
    dynamic error, {
    BuildContext? context,
    VoidCallback? onRetry,
  }) {
    if (context != null) {
      _showErrorDialog(
        context,
        title: 'Connection Error',
        message: 'Please check your internet connection and try again.',
        actionText: onRetry != null ? 'Retry' : null,
        onAction: onRetry,
      );
    }
  }

  static void handleStorageError(dynamic error, {BuildContext? context}) {
    if (context != null) {
      _showErrorDialog(
        context,
        title: 'Storage Error',
        message:
            'Unable to save your progress. Please ensure you have enough storage space.',
      );
    }
  }

  static void handleValidationError(String message, {BuildContext? context}) {
    if (context != null) {
      CustomSnackbar.show(
        context,
        message: message,
        type: SnackbarType.warning,
      );
    }
  }

  static void _showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppConstants.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppConstants.errorColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              message,
              style: const TextStyle(color: AppConstants.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(color: AppConstants.textSecondary),
                ),
              ),
              if (actionText != null && onAction != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onAction();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                  ),
                  child: Text(actionText),
                ),
            ],
          ),
    );
  }
}

// Result wrapper for handling success/error states
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => this is Success<T> ? (this as Success<T>).data : null;
  AppException? get exception =>
      this is Failure<T> ? (this as Failure<T>).exception : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Failure<T>(:final exception) => failure(exception),
    };
  }

  Result<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success<T>(:final data) => Success(transform(data)),
      Failure<T>(:final exception) => Failure(exception),
    };
  }

  Future<Result<R>> mapAsync<R>(Future<R> Function(T) transform) async {
    return switch (this) {
      Success<T>(:final data) => Success(await transform(data)),
      Failure<T>(:final exception) => Failure(exception),
    };
  }
}

// Async operation wrapper
class AsyncOperation {
  static Future<Result<T>> execute<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (error, stackTrace) {
      ErrorHandler._logError(error, stackTrace);

      // Convert to appropriate exception type
      AppException exception;
      if (error is AppException) {
        exception = error;
      } else {
        exception = AppException(
          errorMessage ?? ErrorHandler._getUserFriendlyMessage(error),
          originalError: error,
        );
      }

      return Failure(exception);
    }
  }
}

// Validation utilities
class Validators {
  static ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult.error('Email is required');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.error('Please enter a valid email');
    }

    return ValidationResult.success();
  }

  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult.error('Password is required');
    }

    if (password.length < AppConstants.minPasswordLength) {
      return ValidationResult.error(
        'Password must be at least ${AppConstants.minPasswordLength} characters',
      );
    }

    return ValidationResult.success();
  }

  static ValidationResult validateName(String name) {
    if (name.isEmpty) {
      return ValidationResult.error('Name is required');
    }

    if (name.length > AppConstants.maxNameLength) {
      return ValidationResult.error(
        'Name cannot exceed ${AppConstants.maxNameLength} characters',
      );
    }

    return ValidationResult.success();
  }

  static ValidationResult validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return ValidationResult.error('$fieldName is required');
    }
    return ValidationResult.success();
  }

  static ValidationResult validateLength(
    String value,
    String fieldName, {
    int? min,
    int? max,
  }) {
    if (min != null && value.length < min) {
      return ValidationResult.error(
        '$fieldName must be at least $min characters',
      );
    }

    if (max != null && value.length > max) {
      return ValidationResult.error('$fieldName cannot exceed $max characters');
    }

    return ValidationResult.success();
  }
}

// Validation result
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult._(this.isValid, this.error);

  factory ValidationResult.success() => const ValidationResult._(true, null);
  factory ValidationResult.error(String message) =>
      ValidationResult._(false, message);
}

// Error boundary widget for catching widget errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;

  const ErrorBoundary({super.key, required this.child, this.errorBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? _buildDefaultError();
    }

    return widget.child;
  }

  Widget _buildDefaultError() {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppConstants.errorColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'re sorry for the inconvenience. Please restart the app.',
                style: TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() => _error = null);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      setState(() => _error = details.exception);
      return const SizedBox.shrink();
    };
  }
}

// Global error handler setup
void setupGlobalErrorHandling() {
  // Catch all uncaught framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorHandler.handleError(
      details.exception,
      stackTrace: details.stack,
      showSnackbar: false,
    );
  };

  // Catch all uncaught async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandler.handleError(error, stackTrace: stack, showSnackbar: false);
    return true;
  };
}
