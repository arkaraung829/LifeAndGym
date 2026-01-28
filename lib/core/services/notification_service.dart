import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../models/notification_payload.dart';
import 'logger_service.dart';
import 'navigation_service.dart';

/// Service for managing local notifications.
///
/// This service handles:
/// - Notification initialization
/// - Permission requests (iOS/Android)
/// - Scheduling notifications
/// - Canceling notifications
/// - Handling notification taps
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service.
  ///
  /// Should be called once at app startup.
  Future<void> initialize() async {
    if (_initialized) {
      AppLogger.debug('Notification service already initialized', tag: 'Notifications');
      return;
    }

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // We'll request manually
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create Android notification channel
      await _createAndroidNotificationChannel();

      _initialized = true;
      AppLogger.info('Notification service initialized successfully', tag: 'Notifications');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize notification service',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Create Android notification channel.
  Future<void> _createAndroidNotificationChannel() async {
    try {
      const channel = AndroidNotificationChannel(
        'life_and_gym_channel', // id
        'Life and Gym Notifications', // name
        description: 'Notifications for workout reminders and class bookings',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      AppLogger.debug('Android notification channel created', tag: 'Notifications');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create Android notification channel',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Request notification permissions from the user.
  ///
  /// Returns true if permissions are granted, false otherwise.
  Future<bool> requestPermissions() async {
    try {
      // Request iOS permissions
      final iosPermissions = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Request Android permissions (for Android 13+)
      final androidPermissions = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final granted = (iosPermissions ?? true) && (androidPermissions ?? true);

      if (granted) {
        AppLogger.info('Notification permissions granted', tag: 'Notifications');
      } else {
        AppLogger.warning('Notification permissions denied', tag: 'Notifications');
      }

      return granted;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to request notification permissions',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Schedule a notification.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the notification
  /// - [title]: Notification title
  /// - [body]: Notification body
  /// - [scheduledDate]: When to show the notification
  /// - [payload]: Optional data to pass when notification is tapped
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'life_and_gym_channel',
        'Life and Gym Notifications',
        channelDescription: 'Notifications for workout reminders and class bookings',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert DateTime to TZDateTime
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      AppLogger.info(
        'Notification scheduled: id=$id, time=$scheduledDate',
        tag: 'Notifications',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to schedule notification',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancel a specific notification by ID.
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      AppLogger.info('Notification cancelled: id=$id', tag: 'Notifications');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to cancel notification',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      AppLogger.info('All notifications cancelled', tag: 'Notifications');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to cancel all notifications',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle notification tap.
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;

    AppLogger.info(
      'Notification tapped: id=${response.id}, payload=$payload',
      tag: 'Notifications',
    );

    if (payload == null || payload.isEmpty) return;

    try {
      final notificationPayload = NotificationPayload.fromJson(payload);
      _handleNavigation(notificationPayload);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to parse notification payload',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle navigation based on notification type.
  void _handleNavigation(NotificationPayload payload) {
    final navigationService = NavigationService.instance;

    switch (payload.type) {
      case NotificationType.classReminder:
        // Navigate to class details or bookings
        if (payload.id != null) {
          navigationService.navigateTo('/my-bookings');
        }
        break;
      case NotificationType.workoutReminder:
        // Navigate to workout start screen
        if (payload.id != null) {
          navigationService.navigateTo('/active-workout');
        }
        break;
      case NotificationType.dailyWorkout:
        // Navigate to workouts list
        navigationService.navigateTo('/workouts');
        break;
      case NotificationType.unknown:
        AppLogger.warning('Unknown notification type', tag: 'Notifications');
        break;
    }
  }

  /// Generate a unique notification ID from a string.
  ///
  /// Uses hashCode to create reproducible integer IDs for cancellation.
  int _generateNotificationId(String identifier) {
    return identifier.hashCode.abs();
  }

  /// Schedule a class reminder notification.
  ///
  /// Schedules a notification 30 minutes before the class starts.
  Future<void> scheduleClassReminder(
    String classId,
    String className,
    DateTime classTime,
  ) async {
    try {
      // Schedule 30 minutes before class
      final reminderTime = classTime.subtract(const Duration(minutes: 30));

      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(DateTime.now())) {
        AppLogger.warning(
          'Cannot schedule class reminder in the past: $reminderTime',
          tag: 'Notifications',
        );
        return;
      }

      final notificationId = _generateNotificationId('class_$classId');
      final payload = NotificationPayload.classReminder(
        classId: classId,
      );

      await scheduleNotification(
        id: notificationId,
        title: 'Class Starting Soon',
        body: '$className starts in 30 minutes',
        scheduledDate: reminderTime,
        payload: payload.toJson(),
      );

      AppLogger.info(
        'Class reminder scheduled: $className at $reminderTime',
        tag: 'Notifications',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to schedule class reminder',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Schedule a workout reminder notification.
  ///
  /// Schedules a notification at the specified time.
  Future<void> scheduleWorkoutReminder(
    String workoutId,
    String workoutName,
    DateTime workoutTime,
  ) async {
    try {
      // Don't schedule if time is in the past
      if (workoutTime.isBefore(DateTime.now())) {
        AppLogger.warning(
          'Cannot schedule workout reminder in the past: $workoutTime',
          tag: 'Notifications',
        );
        return;
      }

      final notificationId = _generateNotificationId('workout_$workoutId');
      final payload = NotificationPayload.workoutReminder(
        workoutId: workoutId,
      );

      await scheduleNotification(
        id: notificationId,
        title: 'Workout Reminder',
        body: 'Time for $workoutName',
        scheduledDate: workoutTime,
        payload: payload.toJson(),
      );

      AppLogger.info(
        'Workout reminder scheduled: $workoutName at $workoutTime',
        tag: 'Notifications',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to schedule workout reminder',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Schedule a daily workout reminder.
  ///
  /// Schedules a recurring notification at the specified time each day.
  Future<void> scheduleDailyWorkoutReminder(TimeOfDay time) async {
    try {
      // Create today's scheduled time
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final notificationId = _generateNotificationId('daily_workout');
      final payload = NotificationPayload.dailyWorkoutReminder();

      // Convert to TZDateTime
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'life_and_gym_channel',
        'Life and Gym Notifications',
        channelDescription: 'Notifications for workout reminders and class bookings',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule daily repeating notification
      await _plugin.zonedSchedule(
        notificationId,
        'Time to Work Out!',
        "Don't forget your daily workout",
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload.toJson(),
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      AppLogger.info(
        'Daily workout reminder scheduled: ${time.hour}:${time.minute}',
        tag: 'Notifications',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to schedule daily workout reminder',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancel a class reminder by class ID.
  Future<void> cancelClassReminder(String classId) async {
    final notificationId = _generateNotificationId('class_$classId');
    await cancelNotification(notificationId);
    AppLogger.info('Class reminder cancelled: $classId', tag: 'Notifications');
  }

  /// Cancel a workout reminder by workout ID.
  Future<void> cancelWorkoutReminder(String workoutId) async {
    final notificationId = _generateNotificationId('workout_$workoutId');
    await cancelNotification(notificationId);
    AppLogger.info('Workout reminder cancelled: $workoutId', tag: 'Notifications');
  }

  /// Cancel all daily workout reminders.
  Future<void> cancelDailyReminders() async {
    final notificationId = _generateNotificationId('daily_workout');
    await cancelNotification(notificationId);
    AppLogger.info('Daily workout reminders cancelled', tag: 'Notifications');
  }

  /// Show an immediate notification (for testing purposes).
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'life_and_gym_channel',
        'Life and Gym Notifications',
        channelDescription: 'Notifications for workout reminders and class bookings',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      AppLogger.info('Immediate notification shown: id=$id', tag: 'Notifications');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to show notification',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
