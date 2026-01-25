import 'package:equatable/equatable.dart';

/// User model representing the authenticated user.
class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final String? fitnessLevel;
  final List<String>? fitnessGoals;
  final String preferredUnits;
  final Map<String, dynamic>? notificationPreferences;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.fitnessLevel,
    this.fitnessGoals,
    this.preferredUnits = 'imperial',
    this.notificationPreferences,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (API/Supabase response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: _parseDate(json['date_of_birth']),
      gender: json['gender'] as String?,
      heightCm: _parseDouble(json['height_cm']),
      fitnessLevel: json['fitness_level'] as String?,
      fitnessGoals: _parseStringList(json['fitness_goals']),
      preferredUnits: json['preferred_units'] as String? ?? 'imperial',
      notificationPreferences: json['notification_preferences'] as Map<String, dynamic>?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'gender': gender,
      'height_cm': heightCm,
      'fitness_level': fitnessLevel,
      'fitness_goals': fitnessGoals,
      'preferred_units': preferredUnits,
      'notification_preferences': notificationPreferences,
      'onboarding_completed': onboardingCompleted,
    };
  }

  /// Create a copy with updated fields.
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    String? fitnessLevel,
    List<String>? fitnessGoals,
    String? preferredUnits,
    Map<String, dynamic>? notificationPreferences,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      preferredUnits: preferredUnits ?? this.preferredUnits,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get user's initials for avatar placeholder.
  String get initials {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return '';
    if (names.length == 1) {
      return names.first.isNotEmpty ? names.first[0].toUpperCase() : '';
    }
    return '${names.first[0]}${names.last[0]}'.toUpperCase();
  }

  /// Get age from date of birth.
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Check if user has completed onboarding.
  bool get needsOnboarding => !onboardingCompleted;

  // Helper parsing methods
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
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
        email,
        fullName,
        avatarUrl,
        phone,
        dateOfBirth,
        gender,
        heightCm,
        fitnessLevel,
        fitnessGoals,
        preferredUnits,
        notificationPreferences,
        onboardingCompleted,
        createdAt,
        updatedAt,
      ];
}
