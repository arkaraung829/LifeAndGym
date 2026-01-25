import 'package:equatable/equatable.dart';

import 'workout_model.dart';

/// Workout session model (actual workout performed).
class WorkoutSessionModel extends Equatable {
  final String id;
  final String userId;
  final String? workoutId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationMinutes;
  final int? totalSets;
  final int? totalReps;
  final double? totalWeight;
  final int? caloriesBurned;
  final String? notes;
  final SessionStatus status;
  final DateTime createdAt;

  // Nested workout data
  final WorkoutModel? workout;

  const WorkoutSessionModel({
    required this.id,
    required this.userId,
    this.workoutId,
    required this.startedAt,
    this.completedAt,
    this.durationMinutes,
    this.totalSets,
    this.totalReps,
    this.totalWeight,
    this.caloriesBurned,
    this.notes,
    this.status = SessionStatus.inProgress,
    required this.createdAt,
    this.workout,
  });

  /// Create from JSON (API/Supabase response).
  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      workoutId: json['workout_id'] as String?,
      startedAt: _parseDate(json['started_at']) ?? DateTime.now(),
      completedAt: _parseDate(json['completed_at']),
      durationMinutes: json['duration_minutes'] as int?,
      totalSets: json['total_sets'] as int?,
      totalReps: json['total_reps'] as int?,
      totalWeight: _parseDouble(json['total_weight']),
      caloriesBurned: json['calories_burned'] as int?,
      notes: json['notes'] as String?,
      status: SessionStatus.fromString(json['status'] as String? ?? 'in_progress'),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      workout: json['workouts'] != null
          ? WorkoutModel.fromJson(json['workouts'])
          : null,
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workout_id': workoutId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'total_sets': totalSets,
      'total_reps': totalReps,
      'total_weight': totalWeight,
      'calories_burned': caloriesBurned,
      'notes': notes,
      'status': status.value,
    };
  }

  /// Check if session is currently active.
  bool get isActive => status == SessionStatus.inProgress;

  /// Check if session is completed.
  bool get isCompleted => status == SessionStatus.completed;

  /// Get actual duration or time since start.
  Duration get duration {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    }
    return DateTime.now().difference(startedAt);
  }

  /// Get formatted duration.
  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Create a copy with updated fields.
  WorkoutSessionModel copyWith({
    String? id,
    String? userId,
    String? workoutId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationMinutes,
    int? totalSets,
    int? totalReps,
    double? totalWeight,
    int? caloriesBurned,
    String? notes,
    SessionStatus? status,
    DateTime? createdAt,
    WorkoutModel? workout,
  }) {
    return WorkoutSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutId: workoutId ?? this.workoutId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      totalWeight: totalWeight ?? this.totalWeight,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      workout: workout ?? this.workout,
    );
  }

  // Helper parsing methods
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        workoutId,
        startedAt,
        completedAt,
        durationMinutes,
        totalSets,
        totalReps,
        totalWeight,
        caloriesBurned,
        notes,
        status,
        createdAt,
        workout,
      ];
}

/// Workout session status.
enum SessionStatus {
  inProgress,
  completed,
  cancelled;

  String get value {
    switch (this) {
      case SessionStatus.inProgress:
        return 'in_progress';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.cancelled:
        return 'cancelled';
    }
  }

  static SessionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'in_progress':
        return SessionStatus.inProgress;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      default:
        return SessionStatus.inProgress;
    }
  }
}

/// Workout log (individual exercise set log).
class WorkoutLogModel extends Equatable {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int setNumber;
  final int? reps;
  final double? weight;
  final int? duration;
  final String? notes;
  final DateTime completedAt;

  const WorkoutLogModel({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    this.reps,
    this.weight,
    this.duration,
    this.notes,
    required this.completedAt,
  });

  /// Create from JSON (API/Supabase response).
  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      exerciseId: json['exercise_id'] as String,
      setNumber: json['set_number'] as int,
      reps: json['reps'] as int?,
      weight: _parseDouble(json['weight']),
      duration: json['duration'] as int?,
      notes: json['notes'] as String?,
      completedAt: _parseDate(json['completed_at']) ?? DateTime.now(),
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'notes': notes,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  /// Get formatted log entry.
  String get formattedLog {
    if (reps != null && weight != null) {
      return 'Set $setNumber: $reps reps @ ${weight}kg';
    } else if (reps != null) {
      return 'Set $setNumber: $reps reps';
    } else if (duration != null) {
      return 'Set $setNumber: ${duration}s';
    }
    return 'Set $setNumber';
  }

  // Helper parsing methods
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        exerciseId,
        setNumber,
        reps,
        weight,
        duration,
        notes,
        completedAt,
      ];
}
