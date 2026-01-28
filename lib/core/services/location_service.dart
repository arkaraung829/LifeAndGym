import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';

import 'logger_service.dart';

/// Service for handling location-related operations.
///
/// Provides methods to get current location, check permissions,
/// calculate distances between coordinates, and format distance strings.
class LocationService {
  LocationService._();

  static final LocationService _instance = LocationService._();

  /// Get the singleton instance.
  static LocationService get instance => _instance;

  // Cache for current position (valid for 5 minutes)
  Position? _cachedPosition;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  /// Get current location with permission handling.
  ///
  /// Returns the current position or null if permission is denied
  /// or location services are disabled.
  /// Uses cached position if available and valid.
  Future<Position?> getCurrentLocation() async {
    try {
      // Return cached position if valid
      if (_cachedPosition != null && _cacheTime != null) {
        final now = DateTime.now();
        if (now.difference(_cacheTime!) < _cacheDuration) {
          AppLogger.debug('Using cached location', tag: 'LocationService');
          return _cachedPosition;
        }
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.warning(
          'Location services are disabled',
          tag: 'LocationService',
        );
        return null;
      }

      // Check permission
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        AppLogger.warning(
          'Location permission not granted',
          tag: 'LocationService',
        );
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Cache the position
      _cachedPosition = position;
      _cacheTime = DateTime.now();

      AppLogger.info(
        'Location obtained: ${position.latitude}, ${position.longitude}',
        tag: 'LocationService',
      );

      return position;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get current location',
        tag: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Request location permissions.
  ///
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();

      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (granted) {
        AppLogger.info('Location permission granted', tag: 'LocationService');
      } else {
        AppLogger.warning(
          'Location permission denied: $permission',
          tag: 'LocationService',
        );
      }

      return granted;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to request location permission',
        tag: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Check current permission status.
  ///
  /// Returns true if permission is granted (always or while in use).
  Future<bool> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Try to request permission
        return await requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.warning(
          'Location permission permanently denied',
          tag: 'LocationService',
        );
        return false;
      }

      // Permission is already granted (always or whileInUse)
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check location permission',
        tag: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Calculate distance between two coordinates in kilometers.
  ///
  /// Uses Geolocator's distanceBetween method which implements
  /// the Haversine formula for calculating distances on a sphere.
  ///
  /// Returns distance in meters.
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    try {
      return Geolocator.distanceBetween(
        startLat,
        startLng,
        endLat,
        endLng,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to calculate distance',
        tag: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      return 0.0;
    }
  }

  /// Format distance for display.
  ///
  /// - Less than 1000 meters: shows in meters (e.g., "500 m")
  /// - 1000 meters or more: shows in kilometers with one decimal (e.g., "1.2 km")
  ///
  /// [distanceInMeters] The distance in meters to format.
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Clear cached location.
  ///
  /// Call this when you want to force a fresh location lookup.
  void clearCache() {
    _cachedPosition = null;
    _cacheTime = null;
    AppLogger.debug('Location cache cleared', tag: 'LocationService');
  }

  /// Check if location permission is permanently denied.
  ///
  /// Returns true if permission is permanently denied and the user
  /// needs to manually enable it in device settings.
  Future<bool> isPermissionPermanentlyDenied() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.deniedForever;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check if permission is permanently denied',
        tag: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Open location settings.
  ///
  /// Opens the device's location settings page where the user can
  /// manually enable location permissions.
  /// Uses Geolocator's method which is location-specific.
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to open location settings',
        tag: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Open app settings.
  ///
  /// Opens the app's settings page where the user can manually
  /// enable various permissions including location.
  /// Use this as a fallback if openLocationSettings fails or for general settings access.
  Future<void> openAppSettings() async {
    try {
      await AppSettings.openAppSettings();
      AppLogger.info(
        'Opened app settings',
        tag: 'LocationService',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to open app settings',
        tag: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
