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

import 'app.dart';
import 'config.dart';
import 'firebase_options.dart';
import 'services/preferences_service.dart';
import 'user_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('Starting application initialization', name: 'Main');

  try {
    developer.log('Initializing Firebase', name: 'Main');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase core initialized successfully', name: 'Main');

    developer.log('Configuring Firebase UI Auth providers', name: 'Main');
    firebase_ui_auth.FirebaseUIAuth.configureProviders([
      firebase_ui_auth.EmailAuthProvider(),
      GoogleProvider(clientId: googleClientId),
      AppleProvider(),
    ]);

    // Initialize analytics and performance monitoring
    developer.log('Initializing Firebase Analytics', name: 'Main');
    FirebaseAnalytics.instance;

    developer.log('Initializing Firebase Performance', name: 'Main');
    FirebasePerformance.instance;

    if (!kIsWeb) {
      developer.log('Initializing Firebase Crashlytics', name: 'Main');
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(true);
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    developer.log('Setting up platform error handler', name: 'Main');
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    if (FirebaseAuth.instance.currentUser == null) {
      developer.log('No current user, signing in anonymously', name: 'Main');
      await FirebaseAuth.instance.signInAnonymously();
      developer.log('User authenticated anonymously', name: 'Main');
    } else {
      developer.log('User already authenticated: ${FirebaseAuth.instance.currentUser!.uid}', name: 'Main');
    }

    developer.log('Firebase initialization completed successfully', name: 'Main');
  } catch (error, stackTrace) {
    developer.log('Error during Firebase initialization', name: 'Main', error: error, stackTrace: stackTrace);
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
