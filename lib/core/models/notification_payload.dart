import 'dart:convert';

/// Notification payload model for structured notification data.
class NotificationPayload {
  final NotificationType type;
  final String? id;
  final Map<String, dynamic>? data;

  const NotificationPayload({
    required this.type,
    this.id,
    this.data,
  });

  /// Create from JSON string.
  factory NotificationPayload.fromJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return NotificationPayload(
      type: NotificationType.fromString(json['type'] as String? ?? 'unknown'),
      id: json['id'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON string.
  String toJson() {
    return jsonEncode({
      'type': type.value,
      'id': id,
      'data': data,
    });
  }

  /// Create payload for class reminder.
  factory NotificationPayload.classReminder({
    required String classId,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationPayload(
      type: NotificationType.classReminder,
      id: classId,
      data: additionalData,
    );
  }

  /// Create payload for workout reminder.
  factory NotificationPayload.workoutReminder({
    required String workoutId,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationPayload(
      type: NotificationType.workoutReminder,
      id: workoutId,
      data: additionalData,
    );
  }

  /// Create payload for daily workout reminder.
  factory NotificationPayload.dailyWorkoutReminder() {
    return const NotificationPayload(
      type: NotificationType.dailyWorkout,
    );
  }
}

/// Notification types.
enum NotificationType {
  classReminder,
  workoutReminder,
  dailyWorkout,
  unknown;

  String get value {
    switch (this) {
      case NotificationType.classReminder:
        return 'class';
      case NotificationType.workoutReminder:
        return 'workout';
      case NotificationType.dailyWorkout:
        return 'daily_workout';
      case NotificationType.unknown:
        return 'unknown';
    }
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'class':
        return NotificationType.classReminder;
      case 'workout':
        return NotificationType.workoutReminder;
      case 'daily_workout':
        return NotificationType.dailyWorkout;
      default:
        return NotificationType.unknown;
    }
  }
}
