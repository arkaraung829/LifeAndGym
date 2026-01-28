import 'package:flutter/material.dart';

import '../router/app_router.dart';

/// Service for handling navigation outside of widget context.
///
/// Useful for notifications, background tasks, etc.
class NavigationService {
  NavigationService._();

  static final NavigationService instance = NavigationService._();

  /// Get the global navigator key from AppRouter.
  GlobalKey<NavigatorState> get navigatorKey => AppRouter.router.routerDelegate.navigatorKey;

  /// Get the current BuildContext if available.
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to a path.
  void navigateTo(String path) {
    final context = currentContext;
    if (context != null) {
      AppRouter.router.go(path);
    }
  }

  /// Push a path onto the navigation stack.
  void push(String path) {
    final context = currentContext;
    if (context != null) {
      AppRouter.router.push(path);
    }
  }

  /// Navigate to a named route.
  void navigateToNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    final context = currentContext;
    if (context != null) {
      AppRouter.goNamed(
        context,
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );
    }
  }

  /// Pop the current route.
  void pop([Object? result]) {
    final context = currentContext;
    if (context != null && AppRouter.canPop(context)) {
      AppRouter.pop(context, result);
    }
  }
}
