import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';
import '../services/logger_service.dart';

/// Supabase configuration and initialization.
class SupabaseConfig {
  SupabaseConfig._();

  /// OAuth redirect URL for deep linking.
  static const String redirectUrl = 'lifeandgym://auth-callback';

  /// Supabase URL (set via --dart-define or environment)
  static String get url {
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Default URLs for different environments
    return switch (AppConfig.environment) {
      'production' => 'https://uyqnvvhdeahtcgaglftp.supabase.co',
      'staging' => 'https://uyqnvvhdeahtcgaglftp.supabase.co',
      _ => 'https://uyqnvvhdeahtcgaglftp.supabase.co',
    };
  }

  /// Supabase anonymous key (set via --dart-define or environment)
  static String get anonKey {
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isNotEmpty) return envKey;

    // Default keys for different environments
    return switch (AppConfig.environment) {
      'production' => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5cW52dmhkZWFodGNnYWdsZnRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyNzg0MDcsImV4cCI6MjA4NDg1NDQwN30.mAXP-1fDU3UQzpV-JJ6CCnITnOGDO-1iOUW6h_9hEWE',
      'staging' => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5cW52dmhkZWFodGNnYWdsZnRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyNzg0MDcsImV4cCI6MjA4NDg1NDQwN30.mAXP-1fDU3UQzpV-JJ6CCnITnOGDO-1iOUW6h_9hEWE',
      _ => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5cW52dmhkZWFodGNnYWdsZnRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyNzg0MDcsImV4cCI6MjA4NDg1NDQwN30.mAXP-1fDU3UQzpV-JJ6CCnITnOGDO-1iOUW6h_9hEWE',
    };
  }

  /// Initialize Supabase.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    AppLogger.info('Supabase initialized for ${AppConfig.environment}');
  }

  /// Get the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current authenticated user.
  static User? get currentUser => client.auth.currentUser;

  /// Get the current session.
  static Session? get currentSession => client.auth.currentSession;

  /// Check if user is authenticated.
  static bool get isAuthenticated => currentSession != null;

  /// Get the auth state change stream.
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

/// Database table names.
class Tables {
  Tables._();

  static const String users = 'users';
  static const String gyms = 'gyms';
  static const String memberships = 'memberships';
  static const String checkIns = 'check_ins';
  static const String trainers = 'trainers';
  static const String classes = 'classes';
  static const String classSchedules = 'class_schedules';
  static const String bookings = 'bookings';
  static const String exercises = 'exercises';
  static const String workouts = 'workouts';
  static const String workoutSessions = 'workout_sessions';
  static const String workoutLogs = 'workout_logs';
  static const String goals = 'goals';
  static const String bodyMetrics = 'body_metrics';
  static const String trainingPlans = 'training_plans';
  static const String userTrainingPlans = 'user_training_plans';
  static const String notifications = 'notifications';
}

/// Storage bucket names.
class StorageBuckets {
  StorageBuckets._();

  static const String avatars = 'avatars';
  static const String gymImages = 'gym-images';
  static const String exerciseMedia = 'exercise-media';
  static const String workoutMedia = 'workout-media';
}
