import 'package:equatable/equatable.dart';

import '../../gyms/models/gym_model.dart';

/// Membership model representing a user's gym membership.
class MembershipModel extends Equatable {
  final String id;
  final String userId;
  final String gymId;
  final MembershipPlanType planType;
  final MembershipStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final bool autoRenew;
  final String qrCode;
  final String? homeGymId;
  final bool accessAllLocations;
  final double? monthlyFee;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Nested gym data when joined
  final GymModel? gym;

  const MembershipModel({
    required this.id,
    required this.userId,
    required this.gymId,
    required this.planType,
    required this.status,
    required this.startDate,
    this.endDate,
    this.autoRenew = true,
    required this.qrCode,
    this.homeGymId,
    this.accessAllLocations = false,
    this.monthlyFee,
    required this.createdAt,
    required this.updatedAt,
    this.gym,
  });

  /// Create from JSON (API/Supabase response).
  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gymId: json['gym_id'] as String,
      planType: MembershipPlanType.fromString(json['plan_type'] as String),
      status: MembershipStatus.fromString(json['status'] as String? ?? 'active'),
      startDate: _parseDate(json['start_date']) ?? DateTime.now(),
      endDate: _parseDate(json['end_date']),
      autoRenew: json['auto_renew'] as bool? ?? true,
      qrCode: json['qr_code'] as String,
      homeGymId: json['home_gym_id'] as String?,
      accessAllLocations: json['access_all_locations'] as bool? ?? false,
      monthlyFee: _parseDouble(json['monthly_fee']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      gym: json['gyms'] != null ? GymModel.fromJson(json['gyms']) : null,
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gym_id': gymId,
      'plan_type': planType.value,
      'status': status.value,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'auto_renew': autoRenew,
      'qr_code': qrCode,
      'home_gym_id': homeGymId,
      'access_all_locations': accessAllLocations,
      'monthly_fee': monthlyFee,
    };
  }

  /// Check if membership is currently active.
  bool get isActive => status == MembershipStatus.active;

  /// Check if membership is expired.
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Get days remaining until expiration.
  int? get daysRemaining {
    if (endDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  /// Get renewal date if auto-renew is enabled.
  DateTime? get renewalDate {
    if (!autoRenew || endDate == null) return null;
    return endDate;
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
        gymId,
        planType,
        status,
        startDate,
        endDate,
        autoRenew,
        qrCode,
        homeGymId,
        accessAllLocations,
        monthlyFee,
        createdAt,
        updatedAt,
        gym,
      ];
}

/// Membership plan types.
enum MembershipPlanType {
  basic,
  premium,
  vip,
  dayPass;

  String get value => name.replaceAll('dayPass', 'day_pass');

  String get displayName {
    switch (this) {
      case MembershipPlanType.basic:
        return 'Basic';
      case MembershipPlanType.premium:
        return 'Premium';
      case MembershipPlanType.vip:
        return 'VIP';
      case MembershipPlanType.dayPass:
        return 'Day Pass';
    }
  }

  static MembershipPlanType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'basic':
        return MembershipPlanType.basic;
      case 'premium':
        return MembershipPlanType.premium;
      case 'vip':
        return MembershipPlanType.vip;
      case 'day_pass':
        return MembershipPlanType.dayPass;
      default:
        return MembershipPlanType.basic;
    }
  }
}

/// Membership status.
enum MembershipStatus {
  active,
  paused,
  cancelled,
  expired;

  String get value => name;

  String get displayName {
    switch (this) {
      case MembershipStatus.active:
        return 'Active';
      case MembershipStatus.paused:
        return 'Paused';
      case MembershipStatus.cancelled:
        return 'Cancelled';
      case MembershipStatus.expired:
        return 'Expired';
    }
  }

  static MembershipStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return MembershipStatus.active;
      case 'paused':
        return MembershipStatus.paused;
      case 'cancelled':
        return MembershipStatus.cancelled;
      case 'expired':
        return MembershipStatus.expired;
      default:
        return MembershipStatus.active;
    }
  }
}
