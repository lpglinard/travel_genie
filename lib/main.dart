import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/config.dart';
import 'firebase_options.dart';
import 'providers/user_providers.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firebase_ui_auth.FirebaseUIAuth.configureProviders([
      firebase_ui_auth.EmailAuthProvider(),
      GoogleProvider(clientId: googleClientId, iOSPreferPlist: true),
      AppleProvider(),
    ]);

    // Initialize analytics and performance monitoring
    FirebaseAnalytics.instance;
    FirebasePerformance.instance;

    if (!kIsWeb) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (error, stackTrace) {
    // Error during Firebase initialization
  }

  // Read user locale
  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs);

  // Create a container to override the localeProvider
  final container = ProviderContainer();

  // Check if there's a saved locale preference
  final savedLocale = preferencesService.locale;
  if (savedLocale != null) {
    container.read(localeProvider.notifier).state = savedLocale;
  } else {
    // Get device locale
    final deviceLocale = PlatformDispatcher.instance.locale;

    // Check if device locale is supported (en or pt)
    if (deviceLocale.languageCode == 'en' ||
        deviceLocale.languageCode == 'pt') {
      container.read(localeProvider.notifier).state = deviceLocale;
    } else {
      // Default to 'en' if device locale is not supported
      container.read(localeProvider.notifier).state = const Locale('en');
    }
  }

  runApp(ProviderScope(parent: container, child: const MyApp()));
}
