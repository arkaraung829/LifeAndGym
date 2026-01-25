import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/theme_config.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/classes/providers/classes_provider.dart';
import 'features/gyms/providers/gym_provider.dart';
import 'features/membership/providers/membership_provider.dart';
import 'features/workouts/providers/workout_provider.dart';

/// Main application widget.
class LifeAndGymApp extends StatelessWidget {
  const LifeAndGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GymProvider()),
        ChangeNotifierProvider(create: (_) => MembershipProvider()),
        ChangeNotifierProvider(create: (_) => ClassesProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        // Add more providers here as needed
      ],
      child: MaterialApp.router(
        title: 'LifeAndGym',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.dark, // Default to dark mode

        // Router
        routerConfig: AppRouter.router,
      ),
    );
  }
}
