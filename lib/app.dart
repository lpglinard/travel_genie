import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/infrastructure_providers.dart';
import 'core/theme/theme.dart';
import 'features/user/providers/user_providers.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    ref.listen(userDataProvider, (_, next) async {
      try {
        final prefs = await ref.read(preferencesServiceProvider.future);
        final userData = next.valueOrNull;
        if (userData != null) {
          if (userData.locale != null) {
            ref.read(localeProvider.notifier).state = Locale(userData.locale!);
          }
          if (userData.darkMode != null) {
            ref.read(themeModeProvider.notifier).state = userData.darkMode!
                ? ThemeMode.dark
                : ThemeMode.light;
          }
          await prefs.saveUserData(userData.name, userData.email);
          await prefs.setLocale(
            userData.locale != null ? Locale(userData.locale!) : null,
          );
          if (userData.darkMode != null) {
            await prefs.setThemeMode(
              userData.darkMode! ? ThemeMode.dark : ThemeMode.light,
            );
          }
        } else {
          await prefs.clearAll();
        }
      } catch (e) {
        // Handle preferences service errors gracefully
        debugPrint('Error updating user preferences: $e');
      }
    });

    ref.listen<Locale?>(localeProvider, (_, next) async {
      try {
        final prefs = await ref.read(preferencesServiceProvider.future);
        await prefs.setLocale(next);
        if (next != null) {
          ref.read(analyticsServiceProvider).logLanguageChange(next.languageCode);
        }
      } catch (e) {
        debugPrint('Error updating locale preferences: $e');
      }
    });

    ref.listen<ThemeMode>(themeModeProvider, (_, next) async {
      try {
        final prefs = await ref.read(preferencesServiceProvider.future);
        await prefs.setThemeMode(next);
        ref.read(analyticsServiceProvider).logThemeChange(next.name);
      } catch (e) {
        debugPrint('Error updating theme preferences: $e');
      }
    });

    ref.listen(authStateChangesProvider, (_, next) {
      final user = next.value;
      if (user != null && !user.isAnonymous) {
        // Create or update the user document with basic information only.
        ref.read(firestoreServiceProvider).upsertUser(user);
        ref
            .read(analyticsServiceProvider)
            .logLogin(
              method: user.providerData.isNotEmpty
                  ? user.providerData.first.providerId
                  : 'unknown',
            );
      }
    });

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
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
      routerConfig: router,
    );
  }
}
