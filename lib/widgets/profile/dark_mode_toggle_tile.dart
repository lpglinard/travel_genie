import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/user_providers.dart';

class DarkModeToggleTile extends ConsumerWidget {
  const DarkModeToggleTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final service = ref.read(firestoreServiceProvider);

    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: Text(AppLocalizations.of(context)!.toggleDarkMode),
      trailing: Switch(
        value: themeMode == ThemeMode.dark,
        onChanged: (value) async {
          ref.read(themeModeProvider.notifier).state = value
              ? ThemeMode.dark
              : ThemeMode.light;
          if (user != null && !user.isAnonymous) {
            await service.upsertUser(
              user,
              locale: locale,
              darkMode: value,
            );
          }
          final prefs = await ref.read(preferencesServiceProvider.future);
          await prefs.setThemeMode(
            value ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}