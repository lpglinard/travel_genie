import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/core/providers/infrastructure_providers.dart';
import 'package:travel_genie/features/user/providers/user_providers.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

class LanguageSettingsTile extends ConsumerWidget {
  const LanguageSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final service = ref.read(firestoreServiceProvider);

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(AppLocalizations.of(context)!.changeLanguage),
      trailing: Text(locale == const Locale('en') ? 'EN' : 'PT'),
      onTap: () async {
        if (locale == const Locale('en')) {
          // Change from English to Portuguese
          ref.read(localeProvider.notifier).state = const Locale('pt');
          if (user != null) {
            await service.upsertUser(
              user,
              locale: const Locale('pt'),
              darkMode: themeMode == ThemeMode.dark,
            );
          }
          final prefs = await ref.read(preferencesServiceProvider.future);
          await prefs.setLocale(const Locale('pt'));
        } else {
          // Change from Portuguese (or null) to English
          ref.read(localeProvider.notifier).state = const Locale('en');
          if (user != null) {
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
    );
  }
}
