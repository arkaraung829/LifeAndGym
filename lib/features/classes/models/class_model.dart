import 'package:equatable/equatable.dart';

/// Class model representing a fitness class type.
class ClassModel extends Equatable {
  final String id;
  final String gymId;
  final String? trainerId;
  final String name;
  final String? description;
  final ClassType type;
  final ClassDifficulty? difficulty;
  final int durationMinutes;
  final int capacity;
  final List<String>? equipmentNeeded;
  final String? imageUrl;
  final bool isRecurring;
  final String? recurrenceRule;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClassModel({
    required this.id,
    required this.gymId,
    this.trainerId,
    required this.name,
    this.description,
    required this.type,
    this.difficulty,
    this.durationMinutes = 60,
    this.capacity = 20,
    this.equipmentNeeded,
    this.imageUrl,
    this.isRecurring = true,
    this.recurrenceRule,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (API/Supabase response).
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      gymId: json['gym_id'] as String,
      trainerId: json['trainer_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: ClassType.fromString(json['type'] as String),
      difficulty: json['difficulty'] != null
          ? ClassDifficulty.fromString(json['difficulty'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      capacity: json['capacity'] as int? ?? 20,
      equipmentNeeded: _parseStringList(json['equipment_needed']),
      imageUrl: json['image_url'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? true,
      recurrenceRule: json['recurrence_rule'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gym_id': gymId,
      'trainer_id': trainerId,
      'name': name,
      'description': description,
      'type': type.value,
      'difficulty': difficulty?.value,
      'duration_minutes': durationMinutes,
      'capacity': capacity,
      'equipment_needed': equipmentNeeded,
      'image_url': imageUrl,
      'is_recurring': isRecurring,
      'recurrence_rule': recurrenceRule,
      'is_active': isActive,
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
        gymId,
        trainerId,
        name,
        description,
        type,
        difficulty,
        durationMinutes,
        capacity,
        equipmentNeeded,
        imageUrl,
        isRecurring,
        recurrenceRule,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Class types.
enum ClassType {
  yoga,
  hiit,
  spin,
  pilates,
  strength,
  cardio,
  dance,
  boxing,
  swimming,
  other;

  String get value => name;

  String get displayName {
    switch (this) {
      case ClassType.yoga:
        return 'Yoga';
      case ClassType.hiit:
        return 'HIIT';
      case ClassType.spin:
        return 'Spin';
      case ClassType.pilates:
        return 'Pilates';
      case ClassType.strength:
        return 'Strength';
      case ClassType.cardio:
        return 'Cardio';
      case ClassType.dance:
        return 'Dance';
      case ClassType.boxing:
        return 'Boxing';
      case ClassType.swimming:
        return 'Swimming';
      case ClassType.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ClassType.yoga:
        return '🧘';
      case ClassType.hiit:
        return '🏃';
      case ClassType.spin:
        return '🚴';
      case ClassType.pilates:
        return '🤸';
      case ClassType.strength:
        return '💪';
      case ClassType.cardio:
        return '❤️';
      case ClassType.dance:
        return '💃';
      case ClassType.boxing:
        return '🥊';
      case ClassType.swimming:
        return '🏊';
      case ClassType.other:
        return '⭐';
    }
  }

  static ClassType fromString(String value) {
    return ClassType.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => ClassType.other,
    );
  }
}

/// Class difficulty levels.
enum ClassDifficulty {
  beginner,
  intermediate,
  advanced,
  allLevels;

  String get value => name.replaceAll('allLevels', 'all_levels');

  String get displayName {
    switch (this) {
      case ClassDifficulty.beginner:
        return 'Beginner';
      case ClassDifficulty.intermediate:
        return 'Intermediate';
      case ClassDifficulty.advanced:
        return 'Advanced';
      case ClassDifficulty.allLevels:
        return 'All Levels';
    }
  }

  static ClassDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'beginner':
        return ClassDifficulty.beginner;
      case 'intermediate':
        return ClassDifficulty.intermediate;
      case 'advanced':
        return ClassDifficulty.advanced;
      case 'all_levels':
        return ClassDifficulty.allLevels;
      default:
        return ClassDifficulty.allLevels;
    }
  }
}
