import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences_service.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_providers.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.valueOrNull;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final userData = ref.watch(userDataProvider).valueOrNull;
    final service = ref.read(firestoreServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
      ),
      body: ListView(
        children: [
          if (user != null && !user.isAnonymous)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(userData?.name ?? user.displayName ?? user.email ?? 'User'),
              subtitle: userData?.email != null ? Text(userData!.email!) : null,
            ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.changeLanguage),
            trailing: Text(locale == const Locale('en') ? 'EN' : 'PT'),
            onTap: () async {
              if (locale == const Locale('en')) {
                ref.read(localeProvider.notifier).state = null;
                if (user != null && !user.isAnonymous) {
                  await service.upsertUser(
                    user,
                    locale: null,
                    darkMode: themeMode == ThemeMode.dark,
                  );
                }
                final prefs = await ref.read(preferencesServiceProvider.future);
                await prefs.setLocale(null);
              } else {
                ref.read(localeProvider.notifier).state = const Locale('en');
                if (user != null && !user.isAnonymous) {
                  await service.upsertUser(
                    user,
                    locale: const Locale('en'),
                    darkMode: themeMode == ThemeMode.dark,
                  );
                }
                final prefs = await ref.read(preferencesServiceProvider.future);
                await prefs.setLocale(const Locale('en'));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(AppLocalizations.of(context)!.toggleDarkMode),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) async {
                ref.read(themeModeProvider.notifier).state =
                    value ? ThemeMode.dark : ThemeMode.light;
                if (user != null && !user.isAnonymous) {
                  await service.upsertUser(
                    user,
                    locale: locale,
                    darkMode: value,
                  );
                }
                final prefs = await ref.read(preferencesServiceProvider.future);
                await prefs.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              final prefs = await ref.read(preferencesServiceProvider.future);
              await prefs.clearAll();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
