import 'dart:math' as math;

import '../../../core/config/supabase_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/base_service.dart';
import '../../../core/services/logger_service.dart';
import '../models/gym_model.dart';

/// Service for gym-related operations.
class GymService extends BaseService {
  /// Get all active gyms.
  Future<List<GymModel>> getAllGyms() async {
    try {
      AppLogger.info('Fetching all gyms');

      final response = await supabase
          .from(Tables.gyms)
          .select()
          .eq('is_active', true)
          .order('name');

      final gyms = (response as List)
          .map((json) => GymModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${gyms.length} gyms');
      return gyms;
    } catch (e) {
      AppLogger.error('Failed to fetch gyms', error: e);
      throw DatabaseException(
        'Failed to load gyms',
        
        originalError: e,
      );
    }
  }

  /// Get gym by ID.
  Future<GymModel> getGymById(String gymId) async {
    try {
      AppLogger.info('Fetching gym: $gymId');

      final response = await supabase
          .from(Tables.gyms)
          .select()
          .eq('id', gymId)
          .single();

      final gym = GymModel.fromJson(response);

      AppLogger.info('Fetched gym: ${gym.name}');
      return gym;
    } catch (e) {
      AppLogger.error('Failed to fetch gym', error: e);
      throw DatabaseException(
        'Failed to load gym details',
        
        originalError: e,
      );
    }
  }

  /// Get gym by slug.
  Future<GymModel> getGymBySlug(String slug) async {
    try {
      AppLogger.info('Fetching gym by slug: $slug');

      final response = await supabase
          .from(Tables.gyms)
          .select()
          .eq('slug', slug)
          .single();

      final gym = GymModel.fromJson(response);

      AppLogger.info('Fetched gym: ${gym.name}');
      return gym;
    } catch (e) {
      AppLogger.error('Failed to fetch gym by slug', error: e);
      throw DatabaseException(
        'Failed to load gym',
        
        originalError: e,
      );
    }
  }

  /// Get gyms by city.
  Future<List<GymModel>> getGymsByCity(String city) async {
    try {
      AppLogger.info('Fetching gyms in city: $city');

      final response = await supabase
          .from(Tables.gyms)
          .select()
          .eq('city', city)
          .eq('is_active', true)
          .order('name');

      final gyms = (response as List)
          .map((json) => GymModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${gyms.length} gyms in $city');
      return gyms;
    } catch (e) {
      AppLogger.error('Failed to fetch gyms by city', error: e);
      throw DatabaseException(
        'Failed to load gyms',
        
        originalError: e,
      );
    }
  }

  /// Search gyms by name or location.
  Future<List<GymModel>> searchGyms(String query) async {
    try {
      AppLogger.info('Searching gyms: $query');

      final response = await supabase
          .from(Tables.gyms)
          .select()
          .or('name.ilike.%$query%,city.ilike.%$query%,address.ilike.%$query%')
          .eq('is_active', true)
          .order('name');

      final gyms = (response as List)
          .map((json) => GymModel.fromJson(json))
          .toList();

      AppLogger.info('Found ${gyms.length} gyms matching "$query"');
      return gyms;
    } catch (e) {
      AppLogger.error('Failed to search gyms', error: e);
      throw DatabaseException(
        'Failed to search gyms',
        
        originalError: e,
      );
    }
  }

  /// Get gyms near a location (requires latitude and longitude).
  Future<List<GymModel>> getNearbyGyms({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      AppLogger.info('Fetching gyms near ($latitude, $longitude)');

      // For now, just get all gyms and filter in-memory
      // In production, you'd use PostGIS or similar for proper geospatial queries
      final allGyms = await getAllGyms();

      final nearbyGyms = allGyms.where((gym) {
        if (gym.latitude == null || gym.longitude == null) return false;

        final distance = _calculateDistance(
          latitude,
          longitude,
          gym.latitude!,
          gym.longitude!,
        );

        return distance <= radiusKm;
      }).toList();

      // Sort by distance
      nearbyGyms.sort((a, b) {
        final distA = _calculateDistance(
          latitude,
          longitude,
          a.latitude!,
          a.longitude!,
        );
        final distB = _calculateDistance(
          latitude,
          longitude,
          b.latitude!,
          b.longitude!,
        );
        return distA.compareTo(distB);
      });

      AppLogger.info('Found ${nearbyGyms.length} nearby gyms');
      return nearbyGyms;
    } catch (e) {
      AppLogger.error('Failed to fetch nearby gyms', error: e);
      throw DatabaseException(
        'Failed to find nearby gyms',
        
        originalError: e,
      );
    }
  }

  /// Update gym occupancy (admin only or automated system).
  Future<void> updateOccupancy(String gymId, int currentOccupancy) async {
    try {
      AppLogger.info('Updating gym occupancy: $gymId to $currentOccupancy');

      await supabase
          .from(Tables.gyms)
          .update({
            'current_occupancy': currentOccupancy,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', gymId);

      AppLogger.info('Updated gym occupancy');
    } catch (e) {
      AppLogger.error('Failed to update gym occupancy', error: e);
      throw DatabaseException(
        'Failed to update occupancy',
        
        originalError: e,
      );
    }
  }

  /// Get gym occupancy in real-time.
  Stream<GymModel> streamGymOccupancy(String gymId) {
    return supabase
        .from(Tables.gyms)
        .stream(primaryKey: ['id'])
        .eq('id', gymId)
        .map((data) => GymModel.fromJson(data.first));
  }

  // Private helper: Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
