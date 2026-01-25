import 'package:flutter/foundation.dart';

import '../../../core/providers/safe_change_notifier.dart';
import '../../../core/services/logger_service.dart';
import '../models/booking_model.dart';
import '../models/class_model.dart';
import '../models/class_schedule_model.dart';
import '../services/class_service.dart';

/// Provider state for classes.
enum ClassesState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for class and booking operations.
class ClassesProvider extends ChangeNotifier with SafeChangeNotifierMixin {
  final ClassService _classService;

  ClassesProvider({ClassService? classService})
      : _classService = classService ?? ClassService();

  // State
  ClassesState _state = ClassesState.initial;
  List<ClassModel> _classes = [];
  List<ClassScheduleModel> _schedules = [];
  List<BookingModel> _bookings = [];
  String? _error;

  // Getters
  ClassesState get state => _state;
  List<ClassModel> get classes => _classes;
  List<ClassScheduleModel> get schedules => _schedules;
  List<BookingModel> get bookings => _bookings;
  String? get error => _error;
  bool get isLoading => _state == ClassesState.loading;

  /// Get upcoming schedules (not in the past).
  List<ClassScheduleModel> get upcomingSchedules {
    final now = DateTime.now();
    return _schedules.where((s) => s.scheduledAt.isAfter(now)).toList();
  }

  /// Get user's upcoming bookings.
  List<BookingModel> get upcomingBookings {
    return _bookings
        .where((b) =>
            b.isConfirmed &&
            b.schedule != null &&
            b.schedule!.scheduledAt.isAfter(DateTime.now()))
        .toList();
  }

  /// Load classes for a gym.
  Future<void> loadClasses(String gymId) async {
    _setState(ClassesState.loading);

    try {
      _classes = await _classService.getClassesByGym(gymId);
      _setState(ClassesState.loaded);
      AppLogger.info('Loaded ${_classes.length} classes');
    } catch (e) {
      _setError('Failed to load classes: ${e.toString()}');
      AppLogger.error('Failed to load classes', error: e);
    }
  }

  /// Load schedules for a date range.
  Future<void> loadSchedules({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _schedules = await _classService.getSchedules(
        gymId: gymId,
        startDate: startDate,
        endDate: endDate,
      );
      safeNotifyListeners();
      AppLogger.info('Loaded ${_schedules.length} schedules');
    } catch (e) {
      _setError('Failed to load schedules: ${e.toString()}');
      AppLogger.error('Failed to load schedules', error: e);
    }
  }

  /// Load user's bookings.
  Future<void> loadBookings(String userId) async {
    try {
      _bookings = await _classService.getUserBookings(userId);
      safeNotifyListeners();
      AppLogger.info('Loaded ${_bookings.length} bookings');
    } catch (e) {
      AppLogger.error('Failed to load bookings', error: e);
    }
  }

  /// Book a class.
  Future<bool> bookClass({
    required String userId,
    required String classScheduleId,
  }) async {
    try {
      final booking = await _classService.bookClass(
        userId: userId,
        classScheduleId: classScheduleId,
      );

      _bookings.insert(0, booking);
      safeNotifyListeners();
      AppLogger.info('Booked class successfully');
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Failed to book class', error: e);
      return false;
    }
  }

  /// Cancel a booking.
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _classService.cancelBooking(bookingId);

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.cancelled,
          cancelledAt: DateTime.now(),
        );
      }

      safeNotifyListeners();
      AppLogger.info('Cancelled booking successfully');
      return true;
    } catch (e) {
      _setError('Failed to cancel booking: ${e.toString()}');
      AppLogger.error('Failed to cancel booking', error: e);
      return false;
    }
  }

  /// Clear error.
  void clearError() {
    _error = null;
    if (_state == ClassesState.error) {
      _state = _classes.isNotEmpty || _schedules.isNotEmpty
          ? ClassesState.loaded
          : ClassesState.initial;
    }
    safeNotifyListeners();
  }

  // Private helpers
  void _setState(ClassesState newState) {
    _state = newState;
    _error = null;
    safeNotifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = ClassesState.error;
    safeNotifyListeners();
  }
}
