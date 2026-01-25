/// Application configuration.
///
/// Manages environment-specific settings and constants.
class AppConfig {
  AppConfig._();

  /// Current environment (set via --dart-define)
  /// Use --dart-define=ENV=development for local API testing
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'production',
  );

  /// Whether the app is running in development mode.
  static bool get isDevelopment => environment == 'development';

  /// Whether the app is running in staging mode.
  static bool get isStaging => environment == 'staging';

  /// Whether the app is running in production mode.
  static bool get isProduction => environment == 'production';

  // App Info
  static const String appName = 'LifeAndGym';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetries = 2;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Configuration
  static const Duration defaultCacheDuration = Duration(minutes: 30);
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration longCacheDuration = Duration(hours: 24);

  // Session Configuration
  static const Duration sessionRefreshThreshold = Duration(minutes: 5);

  // Workout Configuration
  static const int defaultRestSeconds = 90;
  static const int minRestSeconds = 10;
  static const int maxRestSeconds = 600;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 4);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;
}

/// Feature flags for enabling/disabling features.
class FeatureFlags {
  FeatureFlags._();

  /// Enable social authentication (Google, Apple).
  static const bool socialAuth = true;

  /// Enable biometric authentication.
  static const bool biometricAuth = true;

  /// Enable push notifications.
  static const bool pushNotifications = true;

  /// Enable workout tracking.
  static const bool workoutTracking = true;

  /// Enable class booking.
  static const bool classBooking = true;

  /// Enable wearable integration (HealthKit, Google Fit).
  static const bool wearableIntegration = false; // Phase 2

  /// Enable AI coaching features.
  static const bool aiCoaching = false; // Phase 3

  /// Enable nutrition tracking.
  static const bool nutritionTracking = false; // Phase 3

  /// Enable social features.
  static const bool socialFeatures = false; // Phase 3
}
