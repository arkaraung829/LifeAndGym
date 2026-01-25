import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/base_service.dart';
import '../../../core/services/logger_service.dart';
import '../models/user_model.dart';

/// Authentication service using Supabase Auth.
///
/// Follows Cuckoo project architecture - Supabase for auth,
/// with profile data in the users table.
class AuthService extends BaseService {
  /// Sign up with email and password.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      AppLogger.auth('Signing up user: $email');

      // Create auth user
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw AppAuthException(
          'Failed to create account',
          type: AuthErrorType.unknown,
        );
      }

      // Create user profile in users table
      final userId = response.user!.id;
      final now = DateTime.now().toIso8601String();

      await supabase.from(Tables.users).insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'created_at': now,
        'updated_at': now,
      });

      AppLogger.auth('User signed up successfully: $userId');

      return UserModel(
        id: userId,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on AppAuthException {
      rethrow;
    } on AuthApiException catch (e) {
      AppLogger.error('Sign up failed', error: e, tag: 'AUTH');
      throw _mapAuthException(e);
    } catch (e) {
      AppLogger.error('Sign up failed', error: e, tag: 'AUTH');
      throw AppAuthException(
        'Failed to create account',
        type: AuthErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Sign in with email and password.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.auth('Signing in user: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppAuthException.invalidCredentials();
      }

      final userId = response.user!.id;

      // Fetch user profile
      final profile = await _fetchUserProfile(userId);

      AppLogger.auth('User signed in successfully: $userId');

      return profile;
    } on AppAuthException {
      rethrow;
    } on AuthApiException catch (e) {
      AppLogger.error('Sign in failed', error: e, tag: 'AUTH');
      throw _mapAuthException(e);
    } catch (e) {
      AppLogger.error('Sign in failed', error: e, tag: 'AUTH');
      throw AppAuthException(
        'Failed to sign in',
        type: AuthErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      AppLogger.auth('Signing out user');
      await supabase.auth.signOut();
      AppLogger.auth('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out failed', error: e, tag: 'AUTH');
      throw AppAuthException(
        'Failed to sign out',
        type: AuthErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.auth('Sending password reset email to: $email');

      await supabase.auth.resetPasswordForEmail(email);

      AppLogger.auth('Password reset email sent');
    } on AuthApiException catch (e) {
      AppLogger.error('Password reset failed', error: e, tag: 'AUTH');
      throw _mapAuthException(e);
    } catch (e) {
      AppLogger.error('Password reset failed', error: e, tag: 'AUTH');
      throw AppAuthException(
        'Failed to send password reset email',
        type: AuthErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Get current user profile.
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      return await _fetchUserProfile(user.id);
    } catch (e) {
      AppLogger.error('Failed to get current user', error: e, tag: 'AUTH');
      return null;
    }
  }

  /// Update user profile.
  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw AppAuthException.sessionExpired();
      }

      AppLogger.auth('Updating profile for user: $userId');

      updates['updated_at'] = DateTime.now().toIso8601String();

      await supabase
          .from(Tables.users)
          .update(updates)
          .eq('id', userId);

      final profile = await _fetchUserProfile(userId);

      AppLogger.auth('Profile updated successfully');

      return profile;
    } catch (e) {
      AppLogger.error('Profile update failed', error: e, tag: 'AUTH');
      throw AppAuthException(
        'Failed to update profile',
        type: AuthErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Complete onboarding.
  Future<UserModel> completeOnboarding({
    required String fitnessLevel,
    required List<String> fitnessGoals,
    String? gender,
    double? heightCm,
    DateTime? dateOfBirth,
  }) async {
    return updateProfile({
      'fitness_level': fitnessLevel,
      'fitness_goals': fitnessGoals,
      'gender': gender,
      'height_cm': heightCm,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'onboarding_completed': true,
    });
  }

  /// Refresh the current session.
  Future<void> refreshSession() async {
    try {
      await supabase.auth.refreshSession();
      AppLogger.auth('Session refreshed');
    } catch (e) {
      AppLogger.error('Session refresh failed', error: e, tag: 'AUTH');
      throw AppAuthException.sessionExpired();
    }
  }

  /// Sign in with Google OAuth.
  Future<bool> signInWithGoogle() async {
    try {
      AppLogger.auth('Starting Google OAuth sign-in');

      final redirectUrl = SupabaseConfig.redirectUrl;
      AppLogger.auth('Using redirect URL: $redirectUrl');

      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
      );

      AppLogger.auth('Google OAuth initiated successfully');
      return true;
    } on AuthApiException catch (e) {
      AppLogger.error('Google OAuth failed', error: e, tag: 'AUTH');
      throw _mapAuthException(e);
    } catch (e) {
      AppLogger.error('Google OAuth error', error: e, tag: 'AUTH');
      throw AppAuthException(
        'Failed to sign in with Google',
        type: AuthErrorType.unknown,
        originalError: e,
      );
    }
  }

  @override
  /// Check if user is authenticated.
  bool get isAuthenticated => supabase.auth.currentSession != null;

  /// Get auth state changes stream.
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  // Private methods

  /// Fetch user profile from database.
  /// Creates profile if it doesn't exist (for OAuth users).
  Future<UserModel> _fetchUserProfile(String userId) async {
    try {
      final response = await supabase
          .from(Tables.users)
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      // If user profile doesn't exist (OAuth first sign-in), create it
      if (e.code == 'PGRST116') {
        AppLogger.auth('User profile not found, creating for OAuth user: $userId');
        return await _createOAuthUserProfile(userId);
      }
      rethrow;
    }
  }

  /// Create user profile for OAuth sign-in.
  Future<UserModel> _createOAuthUserProfile(String userId) async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) {
      throw AppAuthException(
        'No authenticated user found',
        type: AuthErrorType.sessionExpired,
      );
    }

    final email = authUser.email ?? '';
    final fullName = authUser.userMetadata?['full_name'] as String? ??
        authUser.userMetadata?['name'] as String? ??
        email.split('@').first;
    final avatarUrl = authUser.userMetadata?['avatar_url'] as String? ??
        authUser.userMetadata?['picture'] as String?;

    final now = DateTime.now().toIso8601String();

    await supabase.from(Tables.users).insert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'created_at': now,
      'updated_at': now,
    });

    AppLogger.auth('Created user profile for OAuth user: $userId');

    return UserModel(
      id: userId,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Map Supabase auth exception to app exception.
  AppAuthException _mapAuthException(AuthApiException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid') || message.contains('credentials')) {
      return AppAuthException.invalidCredentials();
    }
    if (message.contains('email') && message.contains('already')) {
      return AppAuthException.emailAlreadyInUse();
    }
    if (message.contains('not found') || message.contains('no user')) {
      return AppAuthException.userNotFound();
    }
    if (message.contains('weak') || message.contains('password')) {
      return AppAuthException.weakPassword();
    }
    if (message.contains('expired') || message.contains('session')) {
      return AppAuthException.sessionExpired();
    }
    if (message.contains('verify') || message.contains('confirm')) {
      return AppAuthException.emailNotVerified();
    }

    return AppAuthException(
      e.message,
      type: AuthErrorType.unknown,
      originalError: e,
    );
  }
}
