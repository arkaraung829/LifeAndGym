import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'core/services/cache_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  await _initializeServices();

  runApp(const LifeAndGymApp());
}

Future<void> _initializeServices() async {
  AppLogger.info('Initializing services...');

  try {
    // Initialize Supabase
    await SupabaseConfig.initialize();
    AppLogger.info('Supabase initialized');

    // Initialize cache service
    await CacheService().init();
    AppLogger.info('Cache service initialized');

    // Initialize connectivity service
    ConnectivityService().init();
    AppLogger.info('Connectivity service initialized');

    AppLogger.info('All services initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error(
      'Failed to initialize services',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}
