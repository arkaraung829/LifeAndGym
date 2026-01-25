import 'package:equatable/equatable.dart';

import 'class_model.dart';

/// Class schedule model representing a scheduled class instance.
class ClassScheduleModel extends Equatable {
  final String id;
  final String classId;
  final String gymId;
  final String? trainerId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? room;
  final int capacity;
  final int spotsRemaining;
  final ScheduleStatus status;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Nested class data when joined
  final ClassModel? classInfo;

  const ClassScheduleModel({
    required this.id,
    required this.classId,
    required this.gymId,
    this.trainerId,
    required this.scheduledAt,
    required this.durationMinutes,
    this.room,
    required this.capacity,
    required this.spotsRemaining,
    this.status = ScheduleStatus.scheduled,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.classInfo,
  });

  /// Create from JSON (API/Supabase response).
  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) {
    return ClassScheduleModel(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      gymId: json['gym_id'] as String,
      trainerId: json['trainer_id'] as String?,
      scheduledAt: _parseDate(json['scheduled_at']) ?? DateTime.now(),
      durationMinutes: json['duration_minutes'] as int,
      room: json['room'] as String?,
      capacity: json['capacity'] as int,
      spotsRemaining: json['spots_remaining'] as int,
      status: ScheduleStatus.fromString(json['status'] as String? ?? 'scheduled'),
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      classInfo: json['classes'] != null ? ClassModel.fromJson(json['classes']) : null,
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'gym_id': gymId,
      'trainer_id': trainerId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'room': room,
      'capacity': capacity,
      'spots_remaining': spotsRemaining,
      'status': status.value,
      'cancellation_reason': cancellationReason,
    };
  }

  /// Check if class is full.
  bool get isFull => spotsRemaining == 0;

  /// Check if class is almost full (less than 20% spots remaining).
  bool get isAlmostFull {
    if (capacity == 0) return false;
    final percentage = spotsRemaining / capacity;
    return percentage < 0.2 && !isFull;
  }

  /// Get occupancy percentage.
  double get occupancyPercentage {
    if (capacity == 0) return 0.0;
    return ((capacity - spotsRemaining) / capacity).clamp(0.0, 1.0);
  }

  /// Check if class is in the past.
  bool get isPast => scheduledAt.isBefore(DateTime.now());

  /// Check if class is today.
  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  /// Check if class is upcoming (within next 24 hours).
  bool get isUpcoming {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(hours: 24));
    return scheduledAt.isAfter(now) && scheduledAt.isBefore(tomorrow);
  }

  /// Get time until class starts.
  Duration? get timeUntilStart {
    if (isPast) return null;
    return scheduledAt.difference(DateTime.now());
  }

  /// Get formatted time until start (e.g., "2h 30m", "45m", "starts soon").
  String? get formattedTimeUntilStart {
    final duration = timeUntilStart;
    if (duration == null) return null;

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0 && minutes < 15) return 'Starts soon';
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  /// Get end time.
  DateTime get endTime => scheduledAt.add(Duration(minutes: durationMinutes));

  /// Check if can be booked.
  bool get canBeBooked {
    return status == ScheduleStatus.scheduled && !isFull && !isPast;
  }

  // Helper parsing method
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        classId,
        gymId,
        trainerId,
        scheduledAt,
        durationMinutes,
        room,
        capacity,
        spotsRemaining,
        status,
        cancellationReason,
        createdAt,
        updatedAt,
        classInfo,
      ];
}

/// Schedule status.
enum ScheduleStatus {
  scheduled,
  cancelled,
  completed;

  String get value => name;

  String get displayName {
    switch (this) {
      case ScheduleStatus.scheduled:
        return 'Scheduled';
      case ScheduleStatus.cancelled:
        return 'Cancelled';
      case ScheduleStatus.completed:
        return 'Completed';
    }
  }

  static ScheduleStatus fromString(String value) {
    return ScheduleStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => ScheduleStatus.scheduled,
    );
  }
}
