import 'app_config.dart';

/// API configuration for the Next.js backend.
///
/// Handles all API endpoint definitions and configuration for
/// communicating with the Vercel-deployed Next.js API.
class ApiConfig {
  ApiConfig._();

  /// Base URL for the Next.js API (Vercel)
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    return switch (AppConfig.environment) {
      'production' => 'https://life-and-gym-ktbz.vercel.app',
      'staging' => 'https://life-and-gym-ktbz.vercel.app',
      _ => 'http://localhost:3000', // Local Next.js dev server
    };
  }

  // ==========================================
  // AUTH ENDPOINTS
  // ==========================================
  static const String authPrefix = '/api/auth';
  static String get signUp => '$authPrefix/signup';
  static String get me => '$authPrefix/me';
  static String get profile => '$authPrefix/profile';
  static String get onboarding => '$authPrefix/onboarding';

  // ==========================================
  // GYM ENDPOINTS
  // ==========================================
  static const String gymPrefix = '/api/gyms';
  static String get gyms => gymPrefix;
  static String gymById(String id) => '$gymPrefix/$id';
  static String get gymsSearch => '$gymPrefix/search';
  static String get gymsNearby => '$gymPrefix/nearby';

  // ==========================================
  // MEMBERSHIP ENDPOINTS
  // ==========================================
  static const String membershipPrefix = '/api/memberships';
  static String get memberships => membershipPrefix;
  static String get activeMembership => '$membershipPrefix/active';
  static String get checkIn => '$membershipPrefix/check-in';
  static String get checkOut => '$membershipPrefix/check-out';
  static String get currentCheckIn => '$membershipPrefix/current-check-in';
  static String get checkInHistory => '$membershipPrefix/check-in-history';
  static String get checkInStats => '$membershipPrefix/check-in-stats';
  static String get upgradeMembership => '$membershipPrefix/upgrade';

  // ==========================================
  // WORKOUT ENDPOINTS
  // ==========================================
  static const String workoutPrefix = '/api/workouts';
  static String get exercises => '$workoutPrefix/exercises';
  static String get workouts => workoutPrefix;
  static String get publicWorkouts => '$workoutPrefix/public';
  static String get workoutSessions => '$workoutPrefix/sessions';
  static String get activeWorkoutSession => '$workoutPrefix/sessions/active';
  static String workoutSessionLog(String sessionId) =>
      '$workoutPrefix/sessions/$sessionId/log';
  static String workoutSessionComplete(String sessionId) =>
      '$workoutPrefix/sessions/$sessionId/complete';
  static String get workoutHistory => '$workoutPrefix/history';
  static String get workoutStats => '$workoutPrefix/stats';

  // ==========================================
  // CLASS ENDPOINTS
  // ==========================================
  static const String classPrefix = '/api/classes';
  static String get classes => classPrefix;
  static String get classSchedules => '$classPrefix/schedules';
  static String get bookings => '$classPrefix/bookings';
  static String cancelBooking(String bookingId) =>
      '$classPrefix/bookings/$bookingId/cancel';

  // ==========================================
  // GOALS ENDPOINTS
  // ==========================================
  static const String _apiBase = '';
  static String get goalsBase => '$_apiBase/goals';
  static String goals() => goalsBase;
  static String goalProgress(String goalId) => '$goalsBase/$goalId/progress';

  // ==========================================
  // BODY METRICS ENDPOINTS
  // ==========================================
  static String get metricsBase => '$_apiBase/metrics';
  static String metrics() => metricsBase;
  static String metricsTrends() => '$metricsBase/trends';

  // ==========================================
  // NETWORK CONFIGURATION
  // ==========================================
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 30;
  static const int maxRetries = 2;

  /// Get headers with authentication token.
  static Map<String, String> headersWithAuth(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get headers without authentication.
  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
