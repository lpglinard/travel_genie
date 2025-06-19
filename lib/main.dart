import 'package:firebase_app_check/firebase_app_check.dart' as app_check;
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config.dart';
import 'firebase_options.dart';
import 'services/preferences_service.dart';
import 'user_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await app_check.FirebaseAppCheck.instance.activate(
      // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
      // argument for `webProvider`
      webProvider: app_check.ReCaptchaV3Provider(recaptchaSiteKey),
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Safety Net provider
      // 3. Play Integrity provider
      androidProvider: app_check.AndroidProvider.playIntegrity,
      // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Device Check provider
      // 3. App Attest provider
      // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
      appleProvider: app_check.AppleProvider.appAttest,
    );

    firebase_ui_auth.FirebaseUIAuth.configureProviders([
      firebase_ui_auth.EmailAuthProvider(),
      GoogleProvider(clientId: googleClientId),
      AppleProvider(),
    ]);
    // Initialize analytics and performance monitoring
    FirebaseAnalytics.instance;
    FirebasePerformance.instance;
    if (!kIsWeb) {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(true);
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      print('Usuário autenticado anonimamente');
    }
    print("Firebase inicializado com sucesso");
  } catch (error) {
    print("Erro ao inicializar o Firebase: $error");
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
