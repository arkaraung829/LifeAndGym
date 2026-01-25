import 'package:equatable/equatable.dart';

import 'exercise_model.dart';

/// Workout template model.
class WorkoutModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? category;
  final int estimatedDuration;
  final String difficulty;
  final List<String>? targetMuscles;
  final bool isTemplate;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.category,
    required this.estimatedDuration,
    required this.difficulty,
    this.targetMuscles,
    this.isTemplate = false,
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (API/Supabase response).
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      estimatedDuration: json['estimated_duration'] as int? ?? 30,
      difficulty: json['difficulty'] as String? ?? 'intermediate',
      targetMuscles: _parseStringList(json['target_muscles']),
      isTemplate: json['is_template'] as bool? ?? false,
      isPublic: json['is_public'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'category': category,
      'estimated_duration': estimatedDuration,
      'difficulty': difficulty,
      'target_muscles': targetMuscles,
      'is_template': isTemplate,
      'is_public': isPublic,
    };
  }

  // Helper parsing methods
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        category,
        estimatedDuration,
        difficulty,
        targetMuscles,
        isTemplate,
        isPublic,
        createdAt,
        updatedAt,
      ];
}

/// Workout exercise (exercise in a workout).
class WorkoutExerciseModel extends Equatable {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int orderIndex;
  final int sets;
  final int? reps;
  final int? duration;
  final double? weight;
  final int? restSeconds;
  final String? notes;
  final DateTime createdAt;

  // Nested exercise data
  final ExerciseModel? exercise;

  const WorkoutExerciseModel({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.orderIndex,
    this.sets = 3,
    this.reps,
    this.duration,
    this.weight,
    this.restSeconds,
    this.notes,
    required this.createdAt,
    this.exercise,
  });

  /// Create from JSON (API/Supabase response).
  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      exerciseId: json['exercise_id'] as String,
      orderIndex: json['order_index'] as int,
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as int?,
      duration: json['duration'] as int?,
      weight: _parseDouble(json['weight']),
      restSeconds: json['rest_seconds'] as int?,
      notes: json['notes'] as String?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      exercise: json['exercises'] != null
          ? ExerciseModel.fromJson(json['exercises'])
          : null,
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'order_index': orderIndex,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'weight': weight,
      'rest_seconds': restSeconds,
      'notes': notes,
    };
  }

  /// Get formatted set description.
  String get setDescription {
    if (reps != null && weight != null) {
      return '$sets sets × $reps reps @ ${weight}kg';
    } else if (reps != null) {
      return '$sets sets × $reps reps';
    } else if (duration != null) {
      return '$sets sets × ${duration}s';
    }
    return '$sets sets';
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
        workoutId,
        exerciseId,
        orderIndex,
        sets,
        reps,
        duration,
        weight,
        restSeconds,
        notes,
        createdAt,
        exercise,
      ];
}
