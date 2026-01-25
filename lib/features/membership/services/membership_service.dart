import 'package:uuid/uuid.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/base_service.dart';
import '../../../core/services/logger_service.dart';
import '../models/check_in_model.dart';
import '../models/membership_model.dart';

/// Service for membership and check-in operations.
class MembershipService extends BaseService {
  final _uuid = const Uuid();

  /// Get user's active membership.
  Future<MembershipModel?> getActiveMembership(String userId) async {
    try {
      AppLogger.info('Fetching active membership for user: $userId');

      final response = await supabase
          .from(Tables.memberships)
          .select('*, gyms!memberships_gym_id_fkey(*)')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) {
        AppLogger.info('No active membership found');
        return null;
      }

      final membership = MembershipModel.fromJson(response);
      AppLogger.info('Fetched active membership: ${membership.id}');
      return membership;
    } catch (e) {
      AppLogger.error('Failed to fetch active membership', error: e);
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

      final response = await supabase
          .from(Tables.memberships)
          .select('*, gyms!memberships_gym_id_fkey(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final memberships = (response as List)
          .map((json) => MembershipModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${memberships.length} memberships');
      return memberships;
    } catch (e) {
      AppLogger.error('Failed to fetch memberships', error: e);
      throw DatabaseException(
        'Failed to load memberships',
        
        originalError: e,
      );
    }
  }

  /// Create a new membership.
  Future<MembershipModel> createMembership({
    required String userId,
    required String gymId,
    required MembershipPlanType planType,
    String? homeGymId,
    bool accessAllLocations = false,
  }) async {
    try {
      AppLogger.info('Creating membership for user: $userId');

      final qrCode = _uuid.v4();
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30)); // 30-day membership

      final data = {
        'user_id': userId,
        'gym_id': gymId,
        'plan_type': planType.value,
        'status': 'active',
        'start_date': now.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'qr_code': qrCode,
        'home_gym_id': homeGymId ?? gymId,
        'access_all_locations': accessAllLocations,
        'auto_renew': true,
      };

      final response = await supabase
          .from(Tables.memberships)
          .insert(data)
          .select('*, gyms!memberships_gym_id_fkey(*)')
          .single();

      final membership = MembershipModel.fromJson(response);
      AppLogger.info('Created membership: ${membership.id}');
      return membership;
    } catch (e) {
      AppLogger.error('Failed to create membership', error: e);
      throw DatabaseException(
        'Failed to create membership',
        
        originalError: e,
      );
    }
  }

  /// Update membership status.
  Future<void> updateMembershipStatus(
    String membershipId,
    MembershipStatus status,
  ) async {
    try {
      AppLogger.info('Updating membership status: $membershipId to $status');

      await supabase
          .from(Tables.memberships)
          .update({
            'status': status.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', membershipId);

      AppLogger.info('Updated membership status');
    } catch (e) {
      AppLogger.error('Failed to update membership status', error: e);
      throw DatabaseException(
        'Failed to update membership',
        
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

      // Check if already checked in
      final existingCheckIn = await getCurrentCheckIn(userId);
      if (existingCheckIn != null) {
        throw ValidationException(
          'Already checked in to ${existingCheckIn.gym?.name ?? "a gym"}',
          code: 'ALREADY_CHECKED_IN',
        );
      }

      final data = {
        'user_id': userId,
        'gym_id': gymId,
        'membership_id': membershipId,
        'checked_in_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(Tables.checkIns)
          .insert(data)
          .select('*, gyms!check_ins_gym_id_fkey(*)')
          .single();

      final checkIn = CheckInModel.fromJson(response);
      AppLogger.info('Checked in successfully: ${checkIn.id}');

      return checkIn;
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

      final now = DateTime.now();

      // Get the check-in to calculate duration
      final checkInData = await supabase
          .from(Tables.checkIns)
          .select()
          .eq('id', checkInId)
          .single();

      final checkIn = CheckInModel.fromJson(checkInData);
      final durationMinutes = now.difference(checkIn.checkedInAt).inMinutes;

      final response = await supabase
          .from(Tables.checkIns)
          .update({
            'checked_out_at': now.toIso8601String(),
            'duration_minutes': durationMinutes,
          })
          .eq('id', checkInId)
          .select('*, gyms!check_ins_gym_id_fkey(*)')
          .single();

      final updatedCheckIn = CheckInModel.fromJson(response);
      AppLogger.info('Checked out successfully');

      return updatedCheckIn;
    } catch (e) {
      AppLogger.error('Failed to check out', error: e);
      throw DatabaseException(
        'Failed to check out',
        
        originalError: e,
      );
    }
  }

  /// Get current active check-in for a user.
  Future<CheckInModel?> getCurrentCheckIn(String userId) async {
    try {
      final response = await supabase
          .from(Tables.checkIns)
          .select('*, gyms!check_ins_gym_id_fkey(*)')
          .eq('user_id', userId)
          .isFilter('checked_out_at', null)
          .order('checked_in_at', ascending: false)
          .maybeSingle();

      if (response == null) return null;

      return CheckInModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Failed to get current check-in', error: e);
      return null;
    }
  }

  /// Get check-in history for a user.
  Future<List<CheckInModel>> getCheckInHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      AppLogger.info('Fetching check-in history for user: $userId');

      final response = await supabase
          .from(Tables.checkIns)
          .select('*, gyms!check_ins_gym_id_fkey(*)')
          .eq('user_id', userId)
          .order('checked_in_at', ascending: false)
          .limit(limit);

      final checkIns = (response as List)
          .map((json) => CheckInModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${checkIns.length} check-ins');
      return checkIns;
    } catch (e) {
      AppLogger.error('Failed to fetch check-in history', error: e);
      throw DatabaseException(
        'Failed to load check-in history',
        
        originalError: e,
      );
    }
  }

  /// Get check-ins for a specific date range.
  Future<List<CheckInModel>> getCheckInsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.info('Fetching check-ins from $startDate to $endDate');

      final response = await supabase
          .from(Tables.checkIns)
          .select('*, gyms!check_ins_gym_id_fkey(*)')
          .eq('user_id', userId)
          .gte('checked_in_at', startDate.toIso8601String())
          .lte('checked_in_at', endDate.toIso8601String())
          .order('checked_in_at', ascending: false);

      final checkIns = (response as List)
          .map((json) => CheckInModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${checkIns.length} check-ins');
      return checkIns;
    } catch (e) {
      AppLogger.error('Failed to fetch check-ins by date range', error: e);
      throw DatabaseException(
        'Failed to load check-ins',
        
        originalError: e,
      );
    }
  }

  /// Get check-in statistics for a user.
  Future<Map<String, dynamic>> getCheckInStats(String userId) async {
    try {
      AppLogger.info('Fetching check-in stats for user: $userId');

      final now = DateTime.now();
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final thisMonthStart = DateTime(now.year, now.month, 1);

      final allCheckIns = await getCheckInHistory(userId: userId);

      final thisWeek = allCheckIns
          .where((c) => c.checkedInAt.isAfter(thisWeekStart))
          .length;

      final thisMonth = allCheckIns
          .where((c) => c.checkedInAt.isAfter(thisMonthStart))
          .length;

      final totalMinutes = allCheckIns
          .where((c) => c.durationMinutes != null)
          .fold<int>(0, (sum, c) => sum + c.durationMinutes!);

      return {
        'total_check_ins': allCheckIns.length,
        'this_week': thisWeek,
        'this_month': thisMonth,
        'total_minutes': totalMinutes,
        'average_duration_minutes': allCheckIns.isNotEmpty
            ? totalMinutes ~/ allCheckIns.length
            : 0,
      };
    } catch (e) {
      AppLogger.error('Failed to fetch check-in stats', error: e);
      throw DatabaseException(
        'Failed to load statistics',
        
        originalError: e,
      );
    }
  }
}
