import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'pages/home_page.dart';
import 'theme.dart';
import 'user_providers.dart';
import 'firestore_service.dart';
import 'services/preferences_service.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final prefs = ref.read(preferencesServiceProvider);

    ref.listen(userDataProvider, (_, next) {
      final userData = next.valueOrNull;
      if (userData != null) {
        if (userData.locale != null) {
          ref.read(localeProvider.notifier).state = Locale(userData.locale!);
        }
        if (userData.darkMode != null) {
          ref.read(themeModeProvider.notifier).state =
              userData.darkMode! ? ThemeMode.dark : ThemeMode.light;
        }
        prefs.saveUserData(userData.name, userData.email);
        prefs.setLocale(userData.locale != null ? Locale(userData.locale!) : null);
        if (userData.darkMode != null) {
          prefs.setThemeMode(
              userData.darkMode! ? ThemeMode.dark : ThemeMode.light);
        }
      } else {
        prefs.clearAll();
      }
    });

    ref.listen<Locale?>(localeProvider, (_, next) {
      prefs.setLocale(next);
    });

    ref.listen<ThemeMode>(themeModeProvider, (_, next) {
      prefs.setThemeMode(next);
    });

    ref.listen(authStateChangesProvider, (_, next) {
      final user = next.value;
      if (user != null && !user.isAnonymous) {
        ref.read(firestoreServiceProvider).upsertUser(
              user,
              locale: ref.read(localeProvider),
              darkMode: ref.read(themeModeProvider) == ThemeMode.dark,
            );
      }
    });

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pt')],
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MyHomePage(),
    );
  }
}
