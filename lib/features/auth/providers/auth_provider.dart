import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/safe_change_notifier.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/logger_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication state.
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  guest,
  error,
}

/// Authentication provider following Cuckoo project architecture.
///
/// Uses SafeChangeNotifierMixin to prevent setState after dispose errors.
class AuthProvider extends ChangeNotifier with SafeChangeNotifierMixin {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _init();
  }

  // State
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  bool _isGuest = false;
  StreamSubscription<AuthState>? _authSubscription;

  // Cache keys
  static const _guestModeKey = 'guest_mode';

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _isGuest && _status == AuthStatus.guest;
  bool get isLoading => _status == AuthStatus.loading;
  bool get needsOnboarding => _user?.needsOnboarding ?? false;
  bool get hasAccess => isAuthenticated || isGuest;

  /// Initialize auth state listener.
  void _init() {
    AppLogger.auth('Initializing AuthProvider');

    _authSubscription = _authService.authStateChanges.listen(
      _handleAuthStateChange,
      onError: (error) {
        AppLogger.error('Auth state error', error: error, tag: 'AUTH');
        _setError('Authentication error');
      },
    );

    // Check initial auth state
    _checkInitialAuthState();
  }

  /// Check initial authentication state.
  Future<void> _checkInitialAuthState() async {
    AppLogger.auth('Checking initial auth state');

    try {
      final user = await _authService.getCurrentUser();

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        _isGuest = false;
        AppLogger.auth('User already authenticated: ${user.id}');
      } else {
        // Check if guest mode was previously enabled
        final guestValue = await CacheService().get(_guestModeKey);
        final wasGuest = guestValue == true;

        if (wasGuest) {
          _status = AuthStatus.guest;
          _isGuest = true;
          AppLogger.auth('Continuing as guest');
        } else {
          _status = AuthStatus.unauthenticated;
          AppLogger.auth('No authenticated user');
        }
      }
    } catch (e) {
      AppLogger.error('Initial auth check failed', error: e, tag: 'AUTH');
      _status = AuthStatus.unauthenticated;
    }

    safeNotifyListeners();
  }

  /// Handle auth state changes from Supabase.
  void _handleAuthStateChange(AuthState state) {
    AppLogger.auth('Auth state changed: ${state.event}');

    switch (state.event) {
      case AuthChangeEvent.signedIn:
        _onSignedIn(state.session);
        break;
      case AuthChangeEvent.signedOut:
        _onSignedOut();
        break;
      case AuthChangeEvent.tokenRefreshed:
        AppLogger.auth('Token refreshed');
        break;
      case AuthChangeEvent.userUpdated:
        _refreshUserProfile();
        break;
      case AuthChangeEvent.passwordRecovery:
        AppLogger.auth('Password recovery initiated');
        break;
      default:
        break;
    }
  }

  /// Handle signed in event.
  Future<void> _onSignedIn(Session? session) async {
    if (session == null) return;

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        _error = null;
        safeNotifyListeners();
      }
    } catch (e) {
      AppLogger.error('Failed to fetch user on sign in', error: e, tag: 'AUTH');
    }
  }

  /// Handle signed out event.
  void _onSignedOut() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    safeNotifyListeners();
  }

  /// Refresh user profile.
  Future<void> _refreshUserProfile() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
        safeNotifyListeners();
      }
    } catch (e) {
      AppLogger.error('Failed to refresh user profile', error: e, tag: 'AUTH');
    }
  }

  /// Sign up with email and password.
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading();

    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      _status = AuthStatus.authenticated;
      _error = null;
      safeNotifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Sign in with email and password.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();

    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      _error = null;
      safeNotifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    _setLoading();

    try {
      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }

    safeNotifyListeners();
  }

  /// Send password reset email.
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading();

    try {
      await _authService.sendPasswordResetEmail(email);
      _status = AuthStatus.unauthenticated;
      _error = null;
      safeNotifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Sign in with Google OAuth.
  Future<bool> signInWithGoogle() async {
    _setLoading();

    try {
      final success = await _authService.signInWithGoogle();
      // OAuth redirects to browser, so auth state will be updated
      // by the auth state change listener when user returns
      _status = AuthStatus.unauthenticated; // Reset while waiting for callback
      _error = null;
      safeNotifyListeners();
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Update user profile.
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      _user = await _authService.updateProfile(updates);
      safeNotifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Complete onboarding.
  Future<bool> completeOnboarding({
    required String fitnessLevel,
    required List<String> fitnessGoals,
    String? gender,
    double? heightCm,
    DateTime? dateOfBirth,
  }) async {
    try {
      _user = await _authService.completeOnboarding(
        fitnessLevel: fitnessLevel,
        fitnessGoals: fitnessGoals,
        gender: gender,
        heightCm: heightCm,
        dateOfBirth: dateOfBirth,
      );
      safeNotifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Continue as guest.
  Future<void> continueAsGuest() async {
    AppLogger.auth('Continuing as guest');

    _isGuest = true;
    _status = AuthStatus.guest;
    _user = null;
    _error = null;

    // Save guest preference
    await CacheService().set(_guestModeKey, true);

    safeNotifyListeners();
  }

  /// Exit guest mode (go back to auth flow).
  Future<void> exitGuestMode() async {
    AppLogger.auth('Exiting guest mode');

    _isGuest = false;
    _status = AuthStatus.unauthenticated;
    _user = null;
    _error = null;

    // Remove guest preference
    await CacheService().remove(_guestModeKey);

    safeNotifyListeners();
  }

  /// Convert guest to authenticated user.
  Future<void> upgradeFromGuest() async {
    AppLogger.auth('Upgrading from guest to authenticated user');
    await CacheService().remove(_guestModeKey);
    _isGuest = false;
    // Status will be updated by auth state change listener
  }

  /// Clear error.
  void clearError() {
    _error = null;
    if (_status == AuthStatus.error) {
      if (_user != null) {
        _status = AuthStatus.authenticated;
      } else if (_isGuest) {
        _status = AuthStatus.guest;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    }
    safeNotifyListeners();
  }

  // Private helpers

  void _setLoading() {
    _status = AuthStatus.loading;
    _error = null;
    safeNotifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _status = AuthStatus.error;
    safeNotifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
