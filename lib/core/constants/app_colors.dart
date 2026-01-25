import 'package:flutter/material.dart';

/// Application color palette.
///
/// Based on the design system defined in MASTER_PLAN.md.
class AppColors {
  AppColors._();

  // Primary Colors (Indigo)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFA5B4FC);
  static const Color primaryContainer = Color(0xFFE0E7FF);

  // Secondary Colors
  static const Color secondary = Color(0xFF8B5CF6); // Violet
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFC4B5FD);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Neutral Colors - Dark Mode (Default)
  static const Color backgroundDark = Color(0xFF0F172A);      // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B);          // Slate 800
  static const Color surfaceVariantDark = Color(0xFF334155);   // Slate 700
  static const Color onSurfaceDark = Color(0xFFF8FAFC);        // Slate 50
  static const Color onSurfaceDimDark = Color(0xFF94A3B8);     // Slate 400
  static const Color borderDark = Color(0xFF475569);           // Slate 600

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC);      // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);         // White
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);  // Slate 100
  static const Color onSurfaceLight = Color(0xFF0F172A);       // Slate 900
  static const Color onSurfaceDimLight = Color(0xFF64748B);    // Slate 500
  static const Color borderLight = Color(0xFFE2E8F0);          // Slate 200

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  // Gym Occupancy Colors
  static const Color occupancyLow = success;       // 0-40% - Not busy
  static const Color occupancyMedium = warning;    // 41-70% - Moderately busy
  static const Color occupancyHigh = error;        // 71-100% - Very busy

  /// Get occupancy color based on percentage.
  static Color getOccupancyColor(double percentage) {
    if (percentage <= 0.4) return occupancyLow;
    if (percentage <= 0.7) return occupancyMedium;
    return occupancyHigh;
  }

  // Class Type Colors
  static const Map<String, Color> classTypeColors = {
    'yoga': Color(0xFF8B5CF6),      // Violet
    'hiit': Color(0xFFEF4444),      // Red
    'spin': Color(0xFFF59E0B),      // Amber
    'pilates': Color(0xFF06B6D4),   // Cyan
    'strength': Color(0xFF22C55E),  // Green
    'cardio': Color(0xFFEC4899),    // Pink
    'dance': Color(0xFFA855F7),     // Purple
    'boxing': Color(0xFFDC2626),    // Red 600
    'swimming': Color(0xFF0EA5E9),  // Sky
    'other': Color(0xFF64748B),     // Slate
  };

  /// Get color for class type.
  static Color getClassTypeColor(String type) {
    return classTypeColors[type.toLowerCase()] ?? classTypeColors['other']!;
  }

  // Muscle Group Colors
  static const Map<String, Color> muscleGroupColors = {
    'chest': Color(0xFFEF4444),
    'back': Color(0xFF3B82F6),
    'shoulders': Color(0xFFF59E0B),
    'biceps': Color(0xFF22C55E),
    'triceps': Color(0xFF8B5CF6),
    'legs': Color(0xFFEC4899),
    'core': Color(0xFF06B6D4),
    'glutes': Color(0xFFA855F7),
    'cardio': Color(0xFFDC2626),
  };

  /// Get color for muscle group.
  static Color getMuscleGroupColor(String muscleGroup) {
    return muscleGroupColors[muscleGroup.toLowerCase()] ?? primary;
  }
}
