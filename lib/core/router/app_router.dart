import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/workouts/screens/workouts_screen.dart';
import '../../features/classes/screens/classes_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/workouts/screens/active_workout_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../config/supabase_config.dart';
import 'route_names.dart';

/// Application router configuration using GoRouter.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// The main router instance.
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      // Splash screen
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: RoutePaths.welcome,
        name: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Onboarding
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app with bottom navigation (Shell Route)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.workouts,
            name: RouteNames.workouts,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WorkoutsScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.book,
            name: RouteNames.book,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ClassesScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.progress,
            name: RouteNames.progress,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProgressScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Profile routes (outside shell for full screen)
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Workout routes
      GoRoute(
        path: RoutePaths.activeWorkout,
        name: RouteNames.activeWorkout,
        builder: (context, state) => const ActiveWorkoutScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Handle redirects based on authentication state.
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = SupabaseConfig.isAuthenticated;
    final currentPath = state.uri.path;

    // Public routes that don't require authentication
    const publicRoutes = [
      RoutePaths.splash,
      RoutePaths.welcome,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.forgotPassword,
    ];

    // Routes accessible to guests
    const guestAccessibleRoutes = [
      RoutePaths.home,
      RoutePaths.workouts,
      RoutePaths.book,
      RoutePaths.progress,
      RoutePaths.profile,
    ];

    final isPublicRoute = publicRoutes.contains(currentPath);
    final isGuestAccessible = guestAccessibleRoutes.contains(currentPath);

    // If on splash screen, let it handle the redirect
    if (currentPath == RoutePaths.splash) {
      return null;
    }

    // If not authenticated and trying to access protected route
    // (but allow guest-accessible routes)
    if (!isAuthenticated && !isPublicRoute && !isGuestAccessible) {
      return RoutePaths.welcome;
    }

    // If authenticated and trying to access auth routes
    if (isAuthenticated && isPublicRoute && currentPath != RoutePaths.splash) {
      return RoutePaths.home;
    }

    return null;
  }

  /// Navigate to a named route.
  static void goNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    context.goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Push a named route.
  static void pushNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    context.pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Pop the current route.
  static void pop(BuildContext context, [Object? result]) {
    context.pop(result);
  }

  /// Check if can pop.
  static bool canPop(BuildContext context) {
    return context.canPop();
  }
}
