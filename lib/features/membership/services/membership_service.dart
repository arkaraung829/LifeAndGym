import '../../../core/config/api_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/logger_service.dart';
import '../models/check_in_model.dart';
import '../models/membership_model.dart';

/// Service for membership and check-in operations via API.
class MembershipService {
  final ApiClient _apiClient;

  MembershipService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get user's active membership.
  Future<MembershipModel?> getActiveMembership(String userId) async {
    try {
      AppLogger.info('Fetching active membership for user: $userId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.activeMembership,
      );

      final membershipData = response.data['membership'];
      if (membershipData == null) {
        AppLogger.info('No active membership found');
        return null;
      }

      final membership = MembershipModel.fromJson(membershipData);
      AppLogger.info('Fetched active membership: ${membership.id}');
      return membership;
    } on ApiException catch (e) {
      if (e.isUnauthorized) rethrow;
      AppLogger.error('Failed to fetch active membership', error: e);
      throw DatabaseException(
        'Failed to load membership',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Failed to fetch active membership', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to load membership',
        originalError: e,
      );
    }
  }

  /// Get all memberships for a user.
  Future<List<MembershipModel>> getUserMemberships(String userId) async {
    try {
      AppLogger.info('Fetching all memberships for user: $userId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.memberships,
      );

      final membershipsList = response.data['memberships'] as List;
      final memberships =
          membershipsList.map((json) => MembershipModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${memberships.length} memberships');
      return memberships;
    } catch (e) {
      AppLogger.error('Failed to fetch memberships', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to load memberships',
        originalError: e,
      );
    }
  }

  /// Check in to a gym.
  Future<CheckInModel> checkIn({
    required String userId,
    required String gymId,
    required String membershipId,
  }) async {
    try {
      AppLogger.info('Checking in user: $userId to gym: $gymId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.checkIn,
        body: {'gymId': gymId},
      );

      final checkIn = CheckInModel.fromJson(response.data['checkIn']);
      AppLogger.info('Checked in successfully: ${checkIn.id}');
      return checkIn;
    } on ApiException catch (e) {
      if (e.code == 'VALIDATION_ERROR') {
        throw ValidationException(e.message, code: e.code);
      }
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Failed to check in', error: e);
      throw DatabaseException(
        'Failed to check in',
        originalError: e,
      );
    }
  }

  /// Check out from a gym.
  Future<CheckInModel> checkOut(String checkInId) async {
    try {
      AppLogger.info('Checking out: $checkInId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.checkOut,
      );

      final checkIn = CheckInModel.fromJson(response.data['checkIn']);
      AppLogger.info('Checked out successfully');
      return checkIn;
    } catch (e) {
      AppLogger.error('Failed to check out', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to check out',
        originalError: e,
      );
    }
  }

  /// Get current active check-in for a user.
  Future<CheckInModel?> getCurrentCheckIn(String userId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.currentCheckIn,
      );

      final checkInData = response.data['checkIn'];
      if (checkInData == null) return null;

      return CheckInModel.fromJson(checkInData);
    } catch (e) {
      AppLogger.error('Failed to get current check-in', error: e);
      return null;
    }
  }

  /// Get check-in history for a user.
  Future<List<CheckInModel>> getCheckInHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      AppLogger.info('Fetching check-in history for user: $userId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.checkInHistory,
        queryParams: {'limit': limit, 'offset': offset},
      );

      final checkInsList = response.data['checkIns'] as List;
      final checkIns =
          checkInsList.map((json) => CheckInModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${checkIns.length} check-ins');
      return checkIns;
    } catch (e) {
      AppLogger.error('Failed to fetch check-in history', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to load check-in history',
        originalError: e,
      );
    }
  }

  /// Get check-in statistics for a user.
  Future<Map<String, dynamic>> getCheckInStats(String userId) async {
    try {
      AppLogger.info('Fetching check-in stats for user: $userId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.checkInStats,
      );

      final stats = response.data['stats'] as Map<String, dynamic>;
      AppLogger.info('Fetched check-in stats');
      return stats;
    } catch (e) {
      AppLogger.error('Failed to fetch check-in stats', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to load statistics',
        originalError: e,
      );
    }
  }
}
