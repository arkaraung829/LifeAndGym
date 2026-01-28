import 'package:equatable/equatable.dart';

/// Goal type enumeration.
enum GoalType {
  weightLoss,
  muscleGain,
  strength,
  endurance,
  flexibility,
  bodyFat,
  consistency,
}

/// Goal status enumeration.
enum GoalStatus {
  active,
  completed,
  abandoned,
}

/// Goal model.
class GoalModel extends Equatable {
  final String id;
  final String userId;
  final GoalType type;
  final String name;
  final String? description;
  final double targetValue;
  final double currentValue;
  final String unit;
  final DateTime startDate;
  final DateTime targetDate;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GoalModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.description,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.startDate,
    required this.targetDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (API/Supabase response).
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseGoalType(json['type']),
      name: json['name'] as String,
      description: json['description'] as String?,
      targetValue: _parseDouble(json['target_value']) ?? 0.0,
      currentValue: _parseDouble(json['current_value']) ?? 0.0,
      unit: json['unit'] as String? ?? '',
      startDate: _parseDate(json['start_date']) ?? DateTime.now(),
      targetDate: _parseDate(json['target_date']) ?? DateTime.now(),
      status: _parseGoalStatus(json['status']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': _goalTypeToString(type),
      'name': name,
      'description': description,
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit,
      'start_date': startDate.toIso8601String(),
      'target_date': targetDate.toIso8601String(),
      'status': _goalStatusToString(status),
    };
  }

  /// Get progress as percentage (0-100).
  double get progress {
    if (targetValue == 0) return 0;
    final percentage = (currentValue / targetValue) * 100;
    return percentage.clamp(0, 100);
  }

  /// Get days remaining until target date.
  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return difference.inDays;
  }

  /// Check if goal is overdue.
  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && status == GoalStatus.active;
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

  static GoalType _parseGoalType(dynamic value) {
    if (value == null) return GoalType.weightLoss;
    if (value is GoalType) return value;
    if (value is String) {
      return GoalType.values.firstWhere(
        (type) => _goalTypeToString(type) == value,
        orElse: () => GoalType.weightLoss,
      );
    }
    return GoalType.weightLoss;
  }

  static GoalStatus _parseGoalStatus(dynamic value) {
    if (value == null) return GoalStatus.active;
    if (value is GoalStatus) return value;
    if (value is String) {
      return GoalStatus.values.firstWhere(
        (status) => _goalStatusToString(status) == value,
        orElse: () => GoalStatus.active,
      );
    }
    return GoalStatus.active;
  }

  static String _goalTypeToString(GoalType type) {
    return switch (type) {
      GoalType.weightLoss => 'weight_loss',
      GoalType.muscleGain => 'muscle_gain',
      GoalType.strength => 'strength',
      GoalType.endurance => 'endurance',
      GoalType.flexibility => 'flexibility',
      GoalType.bodyFat => 'body_fat',
      GoalType.consistency => 'consistency',
    };
  }

  static String _goalStatusToString(GoalStatus status) {
    return switch (status) {
      GoalStatus.active => 'active',
      GoalStatus.completed => 'completed',
      GoalStatus.abandoned => 'abandoned',
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        name,
        description,
        targetValue,
        currentValue,
        unit,
        startDate,
        targetDate,
        status,
        createdAt,
        updatedAt,
      ];
}
