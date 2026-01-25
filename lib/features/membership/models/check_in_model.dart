import 'package:equatable/equatable.dart';

import '../../gyms/models/gym_model.dart';

/// Check-in model representing a user's gym check-in.
class CheckInModel extends Equatable {
  final String id;
  final String userId;
  final String gymId;
  final String membershipId;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
  final int? durationMinutes;
  final DateTime createdAt;

  // Nested gym data when joined
  final GymModel? gym;

  const CheckInModel({
    required this.id,
    required this.userId,
    required this.gymId,
    required this.membershipId,
    required this.checkedInAt,
    this.checkedOutAt,
    this.durationMinutes,
    required this.createdAt,
    this.gym,
  });

  /// Create from JSON (API/Supabase response).
  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gymId: json['gym_id'] as String,
      membershipId: json['membership_id'] as String,
      checkedInAt: _parseDate(json['checked_in_at']) ?? DateTime.now(),
      checkedOutAt: _parseDate(json['checked_out_at']),
      durationMinutes: json['duration_minutes'] as int?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      gym: json['gyms'] != null ? GymModel.fromJson(json['gyms']) : null,
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gym_id': gymId,
      'membership_id': membershipId,
      'checked_in_at': checkedInAt.toIso8601String(),
      'checked_out_at': checkedOutAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
    };
  }

  /// Check if currently checked in (not checked out yet).
  bool get isActive => checkedOutAt == null;

  /// Get duration of visit (if checked out) or time since check-in.
  Duration get duration {
    if (checkedOutAt != null) {
      return checkedOutAt!.difference(checkedInAt);
    }
    return DateTime.now().difference(checkedInAt);
  }

  /// Get duration in minutes.
  int get durationInMinutes => duration.inMinutes;

  /// Get formatted duration string.
  String get formattedDuration {
    final mins = durationInMinutes;
    if (mins < 60) {
      return '$mins min';
    }
    final hours = mins ~/ 60;
    final remainingMins = mins % 60;
    if (remainingMins == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMins min';
  }

  /// Create a copy with updated fields.
  CheckInModel copyWith({
    String? id,
    String? userId,
    String? gymId,
    String? membershipId,
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
    int? durationMinutes,
    DateTime? createdAt,
    GymModel? gym,
  }) {
    return CheckInModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gymId: gymId ?? this.gymId,
      membershipId: membershipId ?? this.membershipId,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      gym: gym ?? this.gym,
    );
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
        userId,
        gymId,
        membershipId,
        checkedInAt,
        checkedOutAt,
        durationMinutes,
        createdAt,
        gym,
      ];
}
