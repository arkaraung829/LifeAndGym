import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app locale.
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Supported locales.
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('my'), // Myanmar (Burmese)
  ];

  /// Locale display names.
  static const Map<String, String> localeNames = {
    'en': 'English',
    'my': 'မြန်မာ (Myanmar)',
  };

  /// Initialize locale from saved preferences.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);

    if (savedLocale != null) {
      _locale = Locale(savedLocale);
      notifyListeners();
    }
  }

  /// Set the app locale.
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);

    notifyListeners();
  }

  /// Get display name for a locale.
  String getDisplayName(Locale locale) {
    return localeNames[locale.languageCode] ?? locale.languageCode;
  }

  /// Get current locale display name.
  String get currentLocaleName => getDisplayName(_locale);
}
