import 'package:equatable/equatable.dart';

/// Body metrics model for tracking physical measurements and progress.
class BodyMetricsModel extends Equatable {
  final String id;
  final String userId;
  final DateTime recordedAt;
  final double? weight;
  final String weightUnit;
  final double? bodyFat;
  final double? muscleMass;
  final double? bmi;
  final Map<String, double>? measurements;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BodyMetricsModel({
    required this.id,
    required this.userId,
    required this.recordedAt,
    this.weight,
    this.weightUnit = 'kg',
    this.bodyFat,
    this.muscleMass,
    this.bmi,
    this.measurements,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get BMI category based on BMI value.
  String get bmiCategory {
    if (bmi == null) return 'Unknown';
    if (bmi! < 18.5) return 'Underweight';
    if (bmi! < 25) return 'Normal';
    if (bmi! < 30) return 'Overweight';
    return 'Obese';
  }

  /// Placeholder for trend direction (to be implemented with historical data).
  String get trendDirection => 'Stable';

  /// Create from JSON (API/Supabase response).
  factory BodyMetricsModel.fromJson(Map<String, dynamic> json) {
    return BodyMetricsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recordedAt: _parseDate(json['recorded_at']) ?? DateTime.now(),
      weight: _parseDouble(json['weight']),
      weightUnit: json['weight_unit'] as String? ?? 'kg',
      bodyFat: _parseDouble(json['body_fat']),
      muscleMass: _parseDouble(json['muscle_mass']),
      bmi: _parseDouble(json['bmi']),
      measurements: _parseMeasurements(json['measurements']),
      notes: json['notes'] as String?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recorded_at': recordedAt.toIso8601String(),
      'weight': weight,
      'weight_unit': weightUnit,
      'body_fat': bodyFat,
      'muscle_mass': muscleMass,
      'bmi': bmi,
      'measurements': measurements,
      'notes': notes,
    };
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

  static Map<String, double>? _parseMeasurements(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final result = <String, double>{};
      value.forEach((key, val) {
        final doubleVal = _parseDouble(val);
        if (doubleVal != null) {
          result[key.toString()] = doubleVal;
        }
      });
      return result.isEmpty ? null : result;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        recordedAt,
        weight,
        weightUnit,
        bodyFat,
        muscleMass,
        bmi,
        measurements,
        notes,
        createdAt,
        updatedAt,
      ];
}
