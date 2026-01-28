import '../../../core/config/api_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/logger_service.dart';
import '../models/body_metrics_model.dart';

/// Service for managing body metrics and tracking physical progress.
class BodyMetricsService {
  final ApiClient _apiClient;

  BodyMetricsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ==================== METRICS ====================

  /// Get metrics for a user with optional date range.
  Future<List<BodyMetricsModel>> getMetrics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info('Fetching body metrics for user: $userId');

      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.metrics(),
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      final metricsList = response.data['metrics'] as List;
      final metrics =
          metricsList.map((json) => BodyMetricsModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${metrics.length} body metrics entries');
      return metrics;
    } catch (e) {
      AppLogger.error('Failed to fetch body metrics', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch body metrics', originalError: e);
    }
  }

  /// Create a new body metrics entry.
  Future<BodyMetricsModel> createEntry(BodyMetricsModel metrics) async {
    try {
      AppLogger.info('Creating body metrics entry');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.metrics(),
        body: {
          'recordedAt': metrics.recordedAt.toIso8601String(),
          'weight': metrics.weight,
          'weightUnit': metrics.weightUnit,
          'bodyFat': metrics.bodyFat,
          'muscleMass': metrics.muscleMass,
          'bmi': metrics.bmi,
          'measurements': metrics.measurements,
          'notes': metrics.notes,
        },
      );

      final entry = BodyMetricsModel.fromJson(response.data['metrics']);
      AppLogger.info('Created body metrics entry: ${entry.id}');
      return entry;
    } catch (e) {
      AppLogger.error('Failed to create body metrics entry', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to create body metrics entry',
          originalError: e);
    }
  }

  /// Update an existing body metrics entry.
  Future<BodyMetricsModel> updateEntry(
      String id, BodyMetricsModel metrics) async {
    try {
      AppLogger.info('Updating body metrics entry: $id');

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '${ApiConfig.metrics()}/$id',
        body: {
          'recordedAt': metrics.recordedAt.toIso8601String(),
          'weight': metrics.weight,
          'weightUnit': metrics.weightUnit,
          'bodyFat': metrics.bodyFat,
          'muscleMass': metrics.muscleMass,
          'bmi': metrics.bmi,
          'measurements': metrics.measurements,
          'notes': metrics.notes,
        },
      );

      final entry = BodyMetricsModel.fromJson(response.data['metrics']);
      AppLogger.info('Updated body metrics entry');
      return entry;
    } catch (e) {
      AppLogger.error('Failed to update body metrics entry', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to update body metrics entry',
          originalError: e);
    }
  }

  /// Delete a body metrics entry.
  Future<void> deleteEntry(String id) async {
    try {
      AppLogger.info('Deleting body metrics entry: $id');

      await _apiClient.delete(
        '${ApiConfig.metrics()}/$id',
      );

      AppLogger.info('Deleted body metrics entry');
    } catch (e) {
      AppLogger.error('Failed to delete body metrics entry', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to delete body metrics entry',
          originalError: e);
    }
  }

  /// Get trends data for body metrics.
  Future<Map<String, dynamic>> getTrends(String userId,
      {int days = 30}) async {
    try {
      AppLogger.info('Fetching body metrics trends for user: $userId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.metricsTrends(),
        queryParams: {'days': days},
      );

      final trends = response.data['trends'] as Map<String, dynamic>;
      AppLogger.info('Fetched body metrics trends');
      return trends;
    } catch (e) {
      AppLogger.error('Failed to fetch body metrics trends', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch body metrics trends',
          originalError: e);
    }
  }
}
