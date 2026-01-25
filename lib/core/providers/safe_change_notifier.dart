import 'package:flutter/foundation.dart';

/// A mixin that provides safe state notification for ChangeNotifier.
///
/// This prevents "setState called after dispose" errors by checking
/// if the notifier has been disposed before calling notifyListeners().
///
/// Usage:
/// ```dart
/// class MyProvider extends ChangeNotifier with SafeChangeNotifierMixin {
///   void updateState() {
///     // ... update state
///     safeNotifyListeners(); // Use this instead of notifyListeners()
///   }
/// }
/// ```
mixin SafeChangeNotifierMixin on ChangeNotifier {
  bool _disposed = false;

  /// Whether this notifier has been disposed.
  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Safely notifies listeners only if not disposed.
  ///
  /// Use this instead of [notifyListeners()] to prevent errors
  /// when the widget has been unmounted.
  void safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
