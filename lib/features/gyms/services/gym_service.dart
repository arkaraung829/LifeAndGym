import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/logger_service.dart';
import '../models/gym_model.dart';

/// Service for gym-related operations.
/// Uses API for most operations, Supabase directly for streaming.
class GymService {
  final ApiClient _apiClient;
  final SupabaseClient _supabase;

  GymService({ApiClient? apiClient, SupabaseClient? supabase})
      : _apiClient = apiClient ?? ApiClient(),
        _supabase = supabase ?? SupabaseConfig.client;

  /// Get all active gyms.
  Future<List<GymModel>> getAllGyms() async {
    try {
      AppLogger.info('Fetching all gyms');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.gyms,
      );

      final gymsList = response.data['gyms'] as List;
      final gyms = gymsList.map((json) => GymModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${gyms.length} gyms');
      return gyms;
    } catch (e) {
      AppLogger.error('Failed to fetch gyms', error: e);
      if (e is AppException) rethrow;
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

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.gymById(gymId),
      );

      final gym = GymModel.fromJson(response.data['gym']);

      AppLogger.info('Fetched gym: ${gym.name}');
      return gym;
    } catch (e) {
      AppLogger.error('Failed to fetch gym', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to load gym details',
        originalError: e,
      );
    }
  }

  /// Search gyms by name or location.
  Future<List<GymModel>> searchGyms(String query) async {
    try {
      AppLogger.info('Searching gyms: $query');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.gymsSearch,
        queryParams: {'q': query},
      );

      final gymsList = response.data['gyms'] as List;
      final gyms = gymsList.map((json) => GymModel.fromJson(json)).toList();

      AppLogger.info('Found ${gyms.length} gyms matching "$query"');
      return gyms;
    } catch (e) {
      AppLogger.error('Failed to search gyms', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to search gyms',
        originalError: e,
      );
    }
  }

  /// Get gyms near a location.
  Future<List<GymModel>> getNearbyGyms({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      AppLogger.info('Fetching gyms near ($latitude, $longitude)');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.gymsNearby,
        queryParams: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusKm,
        },
      );

      final gymsList = response.data['gyms'] as List;
      final gyms = gymsList.map((json) => GymModel.fromJson(json)).toList();

      AppLogger.info('Found ${gyms.length} nearby gyms');
      return gyms;
    } catch (e) {
      AppLogger.error('Failed to fetch nearby gyms', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to find nearby gyms',
        originalError: e,
      );
    }
  }

  /// Stream gym occupancy updates (Supabase realtime).
  Stream<GymModel> streamGymOccupancy(String gymId) {
    return _supabase
        .from(Tables.gyms)
        .stream(primaryKey: ['id'])
        .eq('id', gymId)
        .map((rows) {
          if (rows.isEmpty) {
            throw DatabaseException('Gym not found');
          }
          return GymModel.fromJson(rows.first);
        });
  }
}
