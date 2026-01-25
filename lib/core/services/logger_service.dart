import 'package:flutter/foundation.dart';

/// Centralized logging service for the application.
///
/// Provides tagged logging with different severity levels.
/// Logs are only printed in debug mode to avoid performance
/// overhead in production.
class AppLogger {
  AppLogger._();

  /// Log a debug message.
  static void debug(String message, {String? tag}) {
    _log('DEBUG', message, tag: tag);
  }

  /// Log an info message.
  static void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag);
  }

  /// Log a warning message.
  static void warning(String message, {String? tag}) {
    _log('WARNING', message, tag: tag);
  }

  /// Log an error message with optional error object and stack trace.
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('ERROR', message, tag: tag);
    if (error != null && kDebugMode) {
      debugPrint('  Error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('  StackTrace: $stackTrace');
    }
  }

  // Domain-specific loggers

  /// Log authentication-related messages.
  static void auth(String message) => _log('AUTH', message);

  /// Log API-related messages.
  static void api(String message) => _log('API', message);

  /// Log network-related messages.
  static void network(String message) => _log('NETWORK', message);

  /// Log storage/cache-related messages.
  static void storage(String message) => _log('STORAGE', message);

  /// Log navigation-related messages.
  static void navigation(String message) => _log('NAV', message);

  /// Log database-related messages.
  static void database(String message) => _log('DB', message);

  /// Log provider/state-related messages.
  static void state(String message) => _log('STATE', message);

  static void _log(String level, String message, {String? tag}) {
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final tagStr = tag != null ? '[$tag] ' : '';
    debugPrint('[$timestamp] [$level] $tagStr$message');
  }
}
