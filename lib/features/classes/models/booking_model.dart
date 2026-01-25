import 'package:equatable/equatable.dart';

import 'class_schedule_model.dart';

/// Booking model representing a user's class booking.
class BookingModel extends Equatable {
  final String id;
  final String userId;
  final String classScheduleId;
  final BookingStatus status;
  final int? waitlistPosition;
  final DateTime bookedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? attendedAt;
  final DateTime createdAt;

  // Nested schedule data when joined
  final ClassScheduleModel? schedule;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.classScheduleId,
    required this.status,
    this.waitlistPosition,
    required this.bookedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.attendedAt,
    required this.createdAt,
    this.schedule,
  });

  /// Create from JSON (API/Supabase response).
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      classScheduleId: json['class_schedule_id'] as String,
      status: BookingStatus.fromString(json['status'] as String? ?? 'confirmed'),
      waitlistPosition: json['waitlist_position'] as int?,
      bookedAt: _parseDate(json['booked_at']) ?? DateTime.now(),
      cancelledAt: _parseDate(json['cancelled_at']),
      cancellationReason: json['cancellation_reason'] as String?,
      attendedAt: _parseDate(json['attended_at']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      schedule: json['class_schedules'] != null
          ? ClassScheduleModel.fromJson(json['class_schedules'])
          : null,
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'class_schedule_id': classScheduleId,
      'status': status.value,
      'waitlist_position': waitlistPosition,
      'booked_at': bookedAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'attended_at': attendedAt?.toIso8601String(),
    };
  }

  /// Check if booking is confirmed.
  bool get isConfirmed => status == BookingStatus.confirmed;

  /// Check if booking is on waitlist.
  bool get isWaitlisted => status == BookingStatus.waitlist;

  /// Check if booking is cancelled.
  bool get isCancelled => status == BookingStatus.cancelled;

  /// Check if user attended the class.
  bool get hasAttended => status == BookingStatus.attended;

  /// Check if booking can be cancelled.
  bool get canBeCancelled {
    return (isConfirmed || isWaitlisted) && cancelledAt == null;
  }

  /// Get time until class (if schedule is loaded).
  Duration? get timeUntilClass {
    if (schedule == null) return null;
    final now = DateTime.now();
    if (schedule!.scheduledAt.isBefore(now)) return null;
    return schedule!.scheduledAt.difference(now);
  }

  /// Check if class is soon (within 1 hour).
  bool get isClassSoon {
    final duration = timeUntilClass;
    if (duration == null) return false;
    return duration.inMinutes <= 60;
  }

  /// Create a copy with updated fields.
  BookingModel copyWith({
    String? id,
    String? userId,
    String? classScheduleId,
    BookingStatus? status,
    int? waitlistPosition,
    DateTime? bookedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? attendedAt,
    DateTime? createdAt,
    ClassScheduleModel? schedule,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      classScheduleId: classScheduleId ?? this.classScheduleId,
      status: status ?? this.status,
      waitlistPosition: waitlistPosition ?? this.waitlistPosition,
      bookedAt: bookedAt ?? this.bookedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      attendedAt: attendedAt ?? this.attendedAt,
      createdAt: createdAt ?? this.createdAt,
      schedule: schedule ?? this.schedule,
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
        classScheduleId,
        status,
        waitlistPosition,
        bookedAt,
        cancelledAt,
        cancellationReason,
        attendedAt,
        createdAt,
        schedule,
      ];
}

/// Booking status.
enum BookingStatus {
  confirmed,
  cancelled,
  attended,
  noShow,
  waitlist;

  String get value => name.replaceAll('noShow', 'no_show');

  String get displayName {
    switch (this) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.attended:
        return 'Attended';
      case BookingStatus.noShow:
        return 'No Show';
      case BookingStatus.waitlist:
        return 'Waitlist';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'attended':
        return BookingStatus.attended;
      case 'no_show':
        return BookingStatus.noShow;
      case 'waitlist':
        return BookingStatus.waitlist;
      default:
        return BookingStatus.confirmed;
    }
  }
}
