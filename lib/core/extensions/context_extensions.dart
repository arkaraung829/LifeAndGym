import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Extension methods on BuildContext for convenient access to common properties.
extension ContextExtensions on BuildContext {
  // Localization
  AppLocalizations get l10n => AppLocalizations.of(this);

  // Theme
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Media Query
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  double get statusBarHeight => padding.top;
  double get bottomPadding => padding.bottom;
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  // Screen Size Breakpoints
  bool get isSmallScreen => screenWidth < 360;
  bool get isMediumScreen => screenWidth >= 360 && screenWidth < 600;
  bool get isLargeScreen => screenWidth >= 600 && screenWidth < 900;
  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 900;

  // Orientation
  Orientation get orientation => mediaQuery.orientation;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // Navigation (go_router provides pop, push, etc.)
  NavigatorState get navigator => Navigator.of(this);

  // Focus
  void unfocus() => FocusScope.of(this).unfocus();
  bool get hasFocus => FocusScope.of(this).hasFocus;

  // Scaffold
  ScaffoldState get scaffold => Scaffold.of(this);
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  void showSnackBar(SnackBar snackBar) {
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(snackBar);
  }

  void hideSnackBar() {
    scaffoldMessenger.hideCurrentSnackBar();
  }
}
