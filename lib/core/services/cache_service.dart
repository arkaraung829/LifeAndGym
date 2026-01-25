import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Service for caching data locally with optional TTL (time-to-live).
///
/// Uses SharedPreferences for persistent storage. Supports automatic
/// expiration of cached items.
class CacheService {
  static final CacheService _instance = CacheService._internal();

  factory CacheService() => _instance;

  CacheService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Initialize the cache service.
  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    AppLogger.storage('CacheService initialized');
  }

  /// Ensure the service is initialized before use.
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  /// Store a value in cache with optional TTL.
  ///
  /// [key] - Unique identifier for the cached item
  /// [value] - The value to cache (must be JSON-serializable)
  /// [ttl] - Optional time-to-live duration
  Future<bool> set<T>(
    String key,
    T value, {
    Duration? ttl,
  }) async {
    await _ensureInitialized();

    try {
      final data = {
        'value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttl?.inMilliseconds,
      };

      final success = await _prefs!.setString(key, jsonEncode(data));
      AppLogger.storage('Cache set: $key (ttl: ${ttl?.inMinutes ?? 'none'}min)');
      return success;
    } catch (e) {
      AppLogger.error('Cache set error', error: e, tag: key);
      return false;
    }
  }

  /// Retrieve a value from cache.
  ///
  /// Returns null if the item doesn't exist or has expired.
  Future<T?> get<T>(String key) async {
    await _ensureInitialized();

    try {
      final raw = _prefs!.getString(key);
      if (raw == null) return null;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final ttl = data['ttl'] as int?;

      // Check if expired
      if (ttl != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(timestamp + ttl);
        if (DateTime.now().isAfter(expiry)) {
          await remove(key);
          AppLogger.storage('Cache expired: $key');
          return null;
        }
      }

      AppLogger.storage('Cache hit: $key');
      return data['value'] as T?;
    } catch (e) {
      AppLogger.error('Cache get error', error: e, tag: key);
      return null;
    }
  }

  /// Check if a cached item exists and is not expired.
  Future<bool> has(String key) async {
    final value = await get(key);
    return value != null;
  }

  /// Remove a specific item from cache.
  Future<bool> remove(String key) async {
    await _ensureInitialized();

    try {
      final success = await _prefs!.remove(key);
      AppLogger.storage('Cache removed: $key');
      return success;
    } catch (e) {
      AppLogger.error('Cache remove error', error: e, tag: key);
      return false;
    }
  }

  /// Remove multiple items matching a prefix.
  Future<void> removeByPrefix(String prefix) async {
    await _ensureInitialized();

    final keys = _prefs!.getKeys().where((key) => key.startsWith(prefix));
    for (final key in keys) {
      await remove(key);
    }
    AppLogger.storage('Cache cleared with prefix: $prefix');
  }

  /// Clear all cached data.
  Future<bool> clear() async {
    await _ensureInitialized();

    try {
      final success = await _prefs!.clear();
      AppLogger.storage('Cache cleared completely');
      return success;
    } catch (e) {
      AppLogger.error('Cache clear error', error: e);
      return false;
    }
  }

  /// Get all cached keys.
  Future<Set<String>> get keys async {
    await _ensureInitialized();
    return _prefs!.getKeys();
  }
}

/// Common cache keys used throughout the app.
class CacheKeys {
  CacheKeys._();

  static const String userProfile = 'user_profile';
  static const String gyms = 'gyms';
  static const String exercises = 'exercises';
  static const String userMembership = 'user_membership';
  static const String classSchedule = 'class_schedule';
  static const String workoutTemplates = 'workout_templates';
  static const String trainingPlans = 'training_plans';

  // Prefix for gym-specific cache
  static String gymDetail(String gymId) => 'gym_$gymId';

  // Prefix for user-specific cache
  static String userWorkouts(String userId) => 'workouts_$userId';
}

/// Common cache durations.
class CacheDurations {
  CacheDurations._();

  static const Duration short = Duration(minutes: 5);
  static const Duration medium = Duration(minutes: 30);
  static const Duration long = Duration(hours: 2);
  static const Duration day = Duration(hours: 24);
  static const Duration week = Duration(days: 7);
}
