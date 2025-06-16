import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'config.dart';
import 'firebase_options.dart';
import 'services/preferences_service.dart';
import 'user_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebase_ui_auth.FirebaseUIAuth.configureProviders([
      firebase_ui_auth.EmailAuthProvider(),
      GoogleProvider(clientId: googleClientId),
      AppleProvider(),
    ]);
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      print('Usuário autenticado anonimamente');
    }
    print("Firebase inicializado com sucesso");
  } catch (error) {
    print("Erro ao inicializar o Firebase: $error");
  }
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
        localeProvider.overrideWithValue(
          StateController(
            prefs.containsKey('locale')
                ? Locale(prefs.getString('locale')!)
                : null,
          ),
        ),
        themeModeProvider.overrideWithValue(
          StateController(
            prefs.getBool('darkMode') == true
                ? ThemeMode.dark
                : ThemeMode.light,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
