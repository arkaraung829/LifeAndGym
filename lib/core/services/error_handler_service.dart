import 'package:flutter/material.dart';
import '../exceptions/exceptions.dart';
import 'logger_service.dart';

/// Centralized error handling service.
///
/// Converts exceptions to user-friendly messages and provides
/// methods to display errors to users via SnackBars or dialogs.
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();

  factory ErrorHandlerService() => _instance;

  ErrorHandlerService._internal();

  /// Handle an error and return a user-friendly message.
  String handleError(dynamic error, {BuildContext? context, String? fallback}) {
    final message = _getUserFriendlyMessage(error, fallback: fallback);

    AppLogger.error(
      'Error handled: $message',
      error: error,
      tag: 'ErrorHandler',
    );

    return message;
  }

  /// Convert an exception to a user-friendly message.
  String _getUserFriendlyMessage(dynamic error, {String? fallback}) {
    if (error is NetworkException) {
      if (error.isTimeout) {
        return 'Request timed out. Please try again.';
      }

      final statusCode = error.statusCode;
      if (statusCode != null) {
        return switch (statusCode) {
          401 => 'Please log in again.',
          403 => 'You don\'t have permission for this action.',
          404 => 'The requested item was not found.',
          429 => 'Too many requests. Please wait a moment.',
          >= 500 && < 600 => 'Server error. Please try again later.',
          _ => error.message.isNotEmpty
              ? error.message
              : 'No internet connection. Please check your network.',
        };
      }

      return error.message.isNotEmpty
          ? error.message
          : 'No internet connection. Please check your network.';
    }

    if (error is AppAuthException) {
      return switch (error.type) {
        AuthErrorType.invalidCredentials => 'Invalid email or password.',
        AuthErrorType.sessionExpired => 'Your session has expired. Please log in again.',
        AuthErrorType.emailNotVerified => 'Please verify your email address.',
        AuthErrorType.userNotFound => 'No account found with this email.',
        AuthErrorType.weakPassword => 'Password is too weak. Use at least 8 characters.',
        AuthErrorType.emailAlreadyInUse => 'An account with this email already exists.',
        AuthErrorType.unknown => 'Authentication error. Please try again.',
      };
    }

    if (error is ValidationException) {
      return error.message;
    }

    if (error is ApiException) {
      if (error.message.isNotEmpty) {
        return error.message;
      }
      return 'An error occurred. Please try again.';
    }

    if (error is CacheException) {
      return 'Error loading cached data.';
    }

    if (error is DatabaseException) {
      return 'Database error. Please try again.';
    }

    if (error is PermissionException) {
      return 'Permission denied: ${error.permission ?? 'unknown'}';
    }

    if (error is AppException) {
      return error.message;
    }

    // Handle generic errors
    if (error is Exception || error is Error) {
      return fallback ?? 'Something went wrong. Please try again.';
    }

    return fallback ?? 'An unexpected error occurred.';
  }

  /// Show an error as a SnackBar.
  void showErrorSnackBar(BuildContext context, dynamic error, {String? fallback}) {
    final message = handleError(error, context: context, fallback: fallback);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show an error as a dialog.
  Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? fallback,
  }) async {
    final message = handleError(error, context: context, fallback: fallback);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 12),
            Text(title ?? 'Error'),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Wrap an async operation with automatic error handling.
  ///
  /// Returns null and shows an error snackbar if the operation fails.
  Future<T?> wrapAsync<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? errorMessage,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (showError && context.mounted) {
        showErrorSnackBar(context, e, fallback: errorMessage);
      }
      return null;
    }
  }

  /// Show a success message as a SnackBar.
  void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show an info message as a SnackBar.
  void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
