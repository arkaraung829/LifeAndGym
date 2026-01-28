import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/logger_service.dart';
import '../services/notification_service.dart';

/// Provider for managing notification preferences.
class NotificationPreferencesProvider extends ChangeNotifier {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _dailyWorkoutReminderKey = 'daily_workout_reminder_enabled';
  static const String _dailyWorkoutReminderHourKey = 'daily_workout_reminder_hour';
  static const String _dailyWorkoutReminderMinuteKey = 'daily_workout_reminder_minute';

  bool _notificationsEnabled = true;
  bool _dailyWorkoutReminderEnabled = false;
  TimeOfDay _dailyWorkoutReminderTime = const TimeOfDay(hour: 9, minute: 0);

  bool get notificationsEnabled => _notificationsEnabled;
  bool get dailyWorkoutReminderEnabled => _dailyWorkoutReminderEnabled;
  TimeOfDay get dailyWorkoutReminderTime => _dailyWorkoutReminderTime;

  /// Initialize notification preferences from saved state.
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      _dailyWorkoutReminderEnabled = prefs.getBool(_dailyWorkoutReminderKey) ?? false;

      final hour = prefs.getInt(_dailyWorkoutReminderHourKey) ?? 9;
      final minute = prefs.getInt(_dailyWorkoutReminderMinuteKey) ?? 0;
      _dailyWorkoutReminderTime = TimeOfDay(hour: hour, minute: minute);

      // Reschedule daily reminder if enabled
      if (_dailyWorkoutReminderEnabled && _notificationsEnabled) {
        await NotificationService.instance.scheduleDailyWorkoutReminder(_dailyWorkoutReminderTime);
      }

      AppLogger.info(
        'Notification preferences initialized: enabled=$_notificationsEnabled, dailyReminder=$_dailyWorkoutReminderEnabled',
        tag: 'NotificationPreferences',
      );

      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize notification preferences',
        tag: 'NotificationPreferences',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set notification enabled state.
  ///
  /// If [enabled] is true, requests notification permissions.
  /// If [enabled] is false, cancels all scheduled notifications.
  ///
  /// Returns true if the operation was successful.
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      // If enabling, request permissions first
      if (enabled) {
        final permissionGranted = await NotificationService.instance.requestPermissions();

        if (!permissionGranted) {
          AppLogger.warning(
            'Notification permissions denied',
            tag: 'NotificationPreferences',
          );
          return false;
        }
      } else {
        // If disabling, cancel all notifications
        await NotificationService.instance.cancelAllNotifications();
      }

      _notificationsEnabled = enabled;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);

      AppLogger.info(
        'Notifications ${enabled ? 'enabled' : 'disabled'}',
        tag: 'NotificationPreferences',
      );

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to set notification enabled state',
        tag: 'NotificationPreferences',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Set daily workout reminder enabled state.
  Future<bool> setDailyWorkoutReminderEnabled(bool enabled) async {
    try {
      if (enabled && !_notificationsEnabled) {
        AppLogger.warning(
          'Cannot enable daily workout reminder when notifications are disabled',
          tag: 'NotificationPreferences',
        );
        return false;
      }

      if (enabled) {
        // Schedule daily reminder
        await NotificationService.instance.scheduleDailyWorkoutReminder(_dailyWorkoutReminderTime);
      } else {
        // Cancel daily reminder
        await NotificationService.instance.cancelDailyReminders();
      }

      _dailyWorkoutReminderEnabled = enabled;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dailyWorkoutReminderKey, enabled);

      AppLogger.info(
        'Daily workout reminder ${enabled ? 'enabled' : 'disabled'}',
        tag: 'NotificationPreferences',
      );

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to set daily workout reminder state',
        tag: 'NotificationPreferences',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Set daily workout reminder time.
  Future<bool> setDailyWorkoutReminderTime(TimeOfDay time) async {
    try {
      _dailyWorkoutReminderTime = time;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyWorkoutReminderHourKey, time.hour);
      await prefs.setInt(_dailyWorkoutReminderMinuteKey, time.minute);

      // Reschedule if enabled
      if (_dailyWorkoutReminderEnabled) {
        await NotificationService.instance.cancelDailyReminders();
        await NotificationService.instance.scheduleDailyWorkoutReminder(time);
      }

      AppLogger.info(
        'Daily workout reminder time set to ${time.hour}:${time.minute}',
        tag: 'NotificationPreferences',
      );

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to set daily workout reminder time',
        tag: 'NotificationPreferences',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
