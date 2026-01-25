import 'package:equatable/equatable.dart';

/// Exercise model representing a single exercise.
class ExerciseModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<String>? instructions;
  final List<String> muscleGroups;
  final List<String>? equipment;
  final String difficulty;
  final String exerciseType;
  final bool isBodyweight;
  final double? metValue;
  final String? videoUrl;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExerciseModel({
    required this.id,
    required this.name,
    this.description,
    this.instructions,
    required this.muscleGroups,
    this.equipment,
    required this.difficulty,
    required this.exerciseType,
    this.isBodyweight = false,
    this.metValue,
    this.videoUrl,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (API/Supabase response).
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      instructions: _parseStringList(json['instructions']),
      muscleGroups: _parseStringList(json['muscle_groups']) ?? [],
      equipment: _parseStringList(json['equipment']),
      difficulty: json['difficulty'] as String? ?? 'intermediate',
      exerciseType: json['exercise_type'] as String? ?? 'strength',
      isBodyweight: json['is_bodyweight'] as bool? ?? false,
      metValue: _parseDouble(json['met_value']),
      videoUrl: json['video_url'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'muscle_groups': muscleGroups,
      'equipment': equipment,
      'difficulty': difficulty,
      'exercise_type': exerciseType,
      'is_bodyweight': isBodyweight,
      'met_value': metValue,
      'video_url': videoUrl,
      'image_url': imageUrl,
    };
  }

  /// Get emoji for exercise type.
  String get typeEmoji {
    switch (exerciseType.toLowerCase()) {
      case 'strength':
        return '💪';
      case 'cardio':
        return '🏃';
      case 'flexibility':
        return '🧘';
      case 'balance':
        return '⚖️';
      case 'plyometrics':
        return '🦘';
      default:
        return '🏋️';
    }
  }

  /// Get primary muscle group.
  String get primaryMuscle => muscleGroups.isNotEmpty ? muscleGroups.first : 'Full Body';

  /// Get equipment list as string.
  String get equipmentList {
    if (isBodyweight) return 'Bodyweight';
    if (equipment == null || equipment!.isEmpty) return 'No equipment';
    return equipment!.join(', ');
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
        name,
        description,
        instructions,
        muscleGroups,
        equipment,
        difficulty,
        exerciseType,
        isBodyweight,
        metValue,
        videoUrl,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}
