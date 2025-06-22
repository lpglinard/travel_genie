import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/user_providers.dart';
import '../widgets/profile/dark_mode_toggle_tile.dart';
import '../widgets/profile/language_settings_tile.dart';
import '../widgets/profile/logout_tile.dart';
import '../widgets/profile/profile_info_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final userData = ref.watch(userDataProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profileTitle)),
      body: ListView(
        children: [
          if (user != null) ProfileInfoTile(user: user, userData: userData),
          const LanguageSettingsTile(),
          const DarkModeToggleTile(),
          const LogoutTile(),
        ],
      ),
    );
  }
}
