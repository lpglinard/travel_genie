import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/config.dart';
import 'firebase_options.dart';
import 'services/preferences_service.dart';
import 'providers/user_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logging
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    developer.log(
      '${record.level.name}: ${record.message}',
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });

  final mainLogger = Logger('Main');
  mainLogger.info('Starting application initialization');

  try {
    mainLogger.info('Initializing Firebase');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    mainLogger.info('Firebase core initialized successfully');

    mainLogger.info('Configuring Firebase UI Auth providers');
    firebase_ui_auth.FirebaseUIAuth.configureProviders([
      firebase_ui_auth.EmailAuthProvider(),
      GoogleProvider(clientId: googleClientId),
      AppleProvider(),
    ]);

    // Initialize analytics and performance monitoring
    mainLogger.info('Initializing Firebase Analytics');
    FirebaseAnalytics.instance;

    mainLogger.info('Initializing Firebase Performance');
    FirebasePerformance.instance;

    if (!kIsWeb) {
      mainLogger.info('Initializing Firebase Crashlytics');
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(true);
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    mainLogger.info('Setting up platform error handler');
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    if (FirebaseAuth.instance.currentUser == null) {
      mainLogger.info('No current user, signing in anonymously');
      await FirebaseAuth.instance.signInAnonymously();
      mainLogger.info('User authenticated anonymously');
    } else {
      mainLogger.info('User already authenticated: ${FirebaseAuth.instance.currentUser!.uid}');
    }

    mainLogger.info('Firebase initialization completed successfully');
  } catch (error, stackTrace) {
    mainLogger.severe('Error during Firebase initialization', error, stackTrace);
  }

  // Read user locale
  mainLogger.info('Reading user locale');
  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs);

  // Create a container to override the localeProvider
  final container = ProviderContainer();

  // Check if there's a saved locale preference
  final savedLocale = preferencesService.locale;
  if (savedLocale != null) {
    mainLogger.info('Using saved locale: ${savedLocale.languageCode}');
    container.read(localeProvider.notifier).state = savedLocale;
  } else {
    // Get device locale
    final deviceLocale = PlatformDispatcher.instance.locale;
    mainLogger.info('Device locale: ${deviceLocale.languageCode}');

    // Check if device locale is supported (en or pt)
    if (deviceLocale.languageCode == 'en' || deviceLocale.languageCode == 'pt') {
      mainLogger.info('Using device locale: ${deviceLocale.languageCode}');
      container.read(localeProvider.notifier).state = deviceLocale;
    } else {
      mainLogger.info('Device locale not supported, using default: en');
      // Default to 'en' if device locale is not supported
      container.read(localeProvider.notifier).state = const Locale('en');
    }
  }

  runApp(
    ProviderScope(
      parent: container,
      child: const MyApp(),
    ),
  );
}
