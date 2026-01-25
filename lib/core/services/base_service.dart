import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../config/app_config.dart';
import '../exceptions/exceptions.dart';
import 'connectivity_service.dart';
import 'logger_service.dart';

/// Base service class providing common functionality for all services.
///
/// Includes:
/// - Supabase client access
/// - Authentication token management with auto-refresh
/// - Connectivity checking
/// - Retry logic for transient failures
abstract class BaseService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final ConnectivityService _connectivity = ConnectivityService();

  /// Get the Supabase client.
  SupabaseClient get supabase => _supabase;

  /// Get the current user ID.
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Check if user is authenticated.
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  /// Get the current auth token, refreshing if needed.
  ///
  /// Returns null if no session exists.
  /// Automatically refreshes the token if it expires within 5 minutes.
  Future<String?> getAuthToken() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      AppLogger.auth('No session available');
      return null;
    }

    // Check if token expires within 5 minutes
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      session.expiresAt! * 1000,
    );
    final timeUntilExpiry = expiresAt.difference(DateTime.now()).inSeconds;

    if (timeUntilExpiry < AppConfig.sessionRefreshThreshold.inSeconds) {
      AppLogger.auth('Token expiring soon, refreshing...');
      try {
        final response = await _supabase.auth.refreshSession();
        return response.session?.accessToken;
      } catch (e) {
        AppLogger.error('Failed to refresh session', error: e, tag: 'AUTH');
        throw AppAuthException.sessionExpired();
      }
    }

    return session.accessToken;
  }

  /// Ensure user is authenticated before making a request.
  ///
  /// Throws [AppAuthException] if not authenticated.
  Future<void> requireAuth() async {
    if (!isAuthenticated) {
      throw AppAuthException.sessionExpired();
    }
    await getAuthToken(); // Ensure token is fresh
  }

  /// Check network connectivity before making a request.
  ///
  /// Throws [NetworkException] if no connection.
  Future<void> requireConnectivity() async {
    if (!await _connectivity.hasConnection) {
      throw NetworkException.noConnection();
    }
  }

  /// Execute a request with connectivity check and retry logic.
  ///
  /// [request] - The async function to execute
  /// [maxRetries] - Maximum number of retry attempts (default: 2)
  /// [requiresAuth] - Whether to check authentication first
  /// [checkConnectivity] - Whether to check connectivity first
  Future<T> executeWithRetry<T>({
    required Future<T> Function() request,
    int maxRetries = AppConfig.maxRetries,
    bool requiresAuth = true,
    bool checkConnectivity = true,
  }) async {
    // Pre-request checks
    if (checkConnectivity) {
      await requireConnectivity();
    }
    if (requiresAuth) {
      await requireAuth();
    }

    int attempts = 0;
    dynamic lastError;

    while (attempts < maxRetries) {
      try {
        return await request();
      } on PostgrestException catch (e) {
        lastError = e;
        attempts++;

        AppLogger.api(
          'Request failed (attempt $attempts/$maxRetries): ${e.message}',
        );

        // Don't retry on certain errors
        if (_isNonRetryableError(e)) {
          throw _mapPostgrestException(e);
        }

        if (attempts < maxRetries) {
          // Exponential backoff
          await Future.delayed(Duration(milliseconds: 500 * attempts));
        }
      } on AppAuthException {
        rethrow;
      } on NetworkException {
        rethrow;
      } catch (e) {
        lastError = e;
        attempts++;

        AppLogger.error(
          'Unexpected error (attempt $attempts/$maxRetries)',
          error: e,
          tag: 'API',
        );

        if (attempts < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
        }
      }
    }

    // All retries exhausted
    if (lastError is PostgrestException) {
      throw _mapPostgrestException(lastError);
    }

    throw ApiException(
      'Request failed after $maxRetries attempts',
      originalError: lastError,
    );
  }

  /// Check if error is non-retryable.
  bool _isNonRetryableError(PostgrestException e) {
    final code = e.code;
    // Don't retry on client errors (4xx) except rate limiting
    if (code != null) {
      final numCode = int.tryParse(code);
      if (numCode != null && numCode >= 400 && numCode < 500 && numCode != 429) {
        return true;
      }
    }
    return false;
  }

  /// Map Postgrest exception to app exception.
  AppException _mapPostgrestException(PostgrestException e) {
    final code = e.code;
    final message = e.message;

    // Check for specific error codes
    if (code == '23505') {
      return ValidationException('This record already exists');
    }
    if (code == '23503') {
      return ValidationException('Referenced record not found');
    }
    if (code == '42501') {
      return PermissionException('Permission denied', permission: 'database');
    }

    // Check for HTTP-like status codes in the code field
    final numCode = int.tryParse(code ?? '');
    if (numCode != null) {
      return NetworkException.fromStatusCode(numCode, message);
    }

    return ApiException(message, code: code, originalError: e);
  }

  /// Execute a simple query without retry logic.
  ///
  /// Useful for read operations that don't need retries.
  Future<T> executeSimple<T>({
    required Future<T> Function() request,
    bool requiresAuth = true,
    bool checkConnectivity = true,
  }) async {
    if (checkConnectivity) {
      await requireConnectivity();
    }
    if (requiresAuth) {
      await requireAuth();
    }

    try {
      return await request();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    }
  }
}
