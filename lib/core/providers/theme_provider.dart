import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme mode.
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Initialize theme mode from saved preferences.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(_themeModeKey);

    if (savedThemeMode != null) {
      _themeMode = _parseThemeMode(savedThemeMode);
      notifyListeners();
    }
  }

  /// Set the app theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(mode));

    notifyListeners();
  }

  /// Parse theme mode from string.
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Convert theme mode to string.
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}
