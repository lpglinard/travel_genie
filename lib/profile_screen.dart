import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'main.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
      ),
      body: ListView(
        children: [
          if (user != null && !user.isAnonymous)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.displayName ?? user.email ?? 'User'),
            ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.changeLanguage),
            trailing: Text(locale == const Locale('en') ? 'EN' : 'PT'),
            onTap: () {
              if (locale == const Locale('en')) {
                ref.read(localeProvider.notifier).state = null;
              } else {
                ref.read(localeProvider.notifier).state = const Locale('en');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
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
