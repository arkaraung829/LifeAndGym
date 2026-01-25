import 'package:flutter/foundation.dart';

import '../../../core/providers/safe_change_notifier.dart';
import '../../../core/services/logger_service.dart';
import '../models/check_in_model.dart';
import '../models/membership_model.dart';
import '../services/membership_service.dart';

/// Provider state for membership.
enum MembershipState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for membership and check-in operations.
class MembershipProvider extends ChangeNotifier with SafeChangeNotifierMixin {
  final MembershipService _membershipService;

  MembershipProvider({MembershipService? membershipService})
      : _membershipService = membershipService ?? MembershipService();

  // State
  MembershipState _state = MembershipState.initial;
  MembershipModel? _activeMembership;
  List<MembershipModel> _allMemberships = [];
  CheckInModel? _currentCheckIn;
  List<CheckInModel> _checkInHistory = [];
  Map<String, dynamic>? _checkInStats;
  String? _error;

  // Getters
  MembershipState get state => _state;
  MembershipModel? get activeMembership => _activeMembership;
  List<MembershipModel> get allMemberships => _allMemberships;
  CheckInModel? get currentCheckIn => _currentCheckIn;
  List<CheckInModel> get checkInHistory => _checkInHistory;
  Map<String, dynamic>? get checkInStats => _checkInStats;
  String? get error => _error;
  bool get isLoading => _state == MembershipState.loading;
  bool get hasMembership => _activeMembership != null;
  bool get isCheckedIn => _currentCheckIn != null;

  /// Load active membership for a user.
  Future<void> loadActiveMembership(String userId) async {
    _setState(MembershipState.loading);

    try {
      _activeMembership = await _membershipService.getActiveMembership(userId);
      _setState(MembershipState.loaded);
      AppLogger.info('Loaded active membership');
    } catch (e) {
      _setError('Failed to load membership: ${e.toString()}');
      AppLogger.error('Failed to load membership', error: e);
    }
  }

  /// Load all memberships for a user.
  Future<void> loadAllMemberships(String userId) async {
    try {
      _allMemberships = await _membershipService.getUserMemberships(userId);
      safeNotifyListeners();
      AppLogger.info('Loaded ${_allMemberships.length} memberships');
    } catch (e) {
      AppLogger.error('Failed to load all memberships', error: e);
    }
  }

  /// Create a new membership.
  Future<bool> createMembership({
    required String userId,
    required String gymId,
    required MembershipPlanType planType,
    String? homeGymId,
    bool accessAllLocations = false,
  }) async {
    _setState(MembershipState.loading);

    try {
      _activeMembership = await _membershipService.createMembership(
        userId: userId,
        gymId: gymId,
        planType: planType,
        homeGymId: homeGymId,
        accessAllLocations: accessAllLocations,
      );
      _setState(MembershipState.loaded);
      AppLogger.info('Created membership');
      return true;
    } catch (e) {
      _setError('Failed to create membership: ${e.toString()}');
      AppLogger.error('Failed to create membership', error: e);
      return false;
    }
  }

  /// Update membership status.
  Future<bool> updateMembershipStatus(
    String membershipId,
    MembershipStatus status,
  ) async {
    try {
      await _membershipService.updateMembershipStatus(membershipId, status);

      if (_activeMembership?.id == membershipId) {
        _activeMembership = null;
      }

      safeNotifyListeners();
      AppLogger.info('Updated membership status');
      return true;
    } catch (e) {
      _setError('Failed to update membership: ${e.toString()}');
      AppLogger.error('Failed to update membership', error: e);
      return false;
    }
  }

  /// Check in to a gym.
  Future<bool> checkIn({
    required String userId,
    required String gymId,
    required String membershipId,
  }) async {
    try {
      _currentCheckIn = await _membershipService.checkIn(
        userId: userId,
        gymId: gymId,
        membershipId: membershipId,
      );
      safeNotifyListeners();
      AppLogger.info('Checked in successfully');
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Failed to check in', error: e);
      return false;
    }
  }

  /// Check out from a gym.
  Future<bool> checkOut() async {
    if (_currentCheckIn == null) {
      _setError('No active check-in');
      return false;
    }

    try {
      final updatedCheckIn = await _membershipService.checkOut(_currentCheckIn!.id);

      // Add to history
      _checkInHistory.insert(0, updatedCheckIn);
      _currentCheckIn = null;

      safeNotifyListeners();
      AppLogger.info('Checked out successfully');
      return true;
    } catch (e) {
      _setError('Failed to check out: ${e.toString()}');
      AppLogger.error('Failed to check out', error: e);
      return false;
    }
  }

  /// Load current check-in status.
  Future<void> loadCurrentCheckIn(String userId) async {
    try {
      _currentCheckIn = await _membershipService.getCurrentCheckIn(userId);
      safeNotifyListeners();
      AppLogger.info('Loaded current check-in status');
    } catch (e) {
      AppLogger.error('Failed to load current check-in', error: e);
    }
  }

  /// Load check-in history.
  Future<void> loadCheckInHistory(String userId) async {
    try {
      _checkInHistory = await _membershipService.getCheckInHistory(
        userId: userId,
      );
      safeNotifyListeners();
      AppLogger.info('Loaded ${_checkInHistory.length} check-ins');
    } catch (e) {
      AppLogger.error('Failed to load check-in history', error: e);
    }
  }

  /// Load check-in statistics.
  Future<void> loadCheckInStats(String userId) async {
    try {
      _checkInStats = await _membershipService.getCheckInStats(userId);
      safeNotifyListeners();
      AppLogger.info('Loaded check-in stats');
    } catch (e) {
      AppLogger.error('Failed to load check-in stats', error: e);
    }
  }

  /// Initialize membership data for a user.
  Future<void> initializeMembershipData(String userId) async {
    await loadActiveMembership(userId);
    await loadCurrentCheckIn(userId);
    await loadCheckInHistory(userId);
  }

  /// Clear error.
  void clearError() {
    _error = null;
    if (_state == MembershipState.error) {
      _state = _activeMembership != null
          ? MembershipState.loaded
          : MembershipState.initial;
    }
    safeNotifyListeners();
  }

  // Private helpers
  void _setState(MembershipState newState) {
    _state = newState;
    _error = null;
    safeNotifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = MembershipState.error;
    safeNotifyListeners();
  }
}
