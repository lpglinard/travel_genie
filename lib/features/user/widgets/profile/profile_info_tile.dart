import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/features/user/models/user_data.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({super.key, required this.user, this.userData});

  final User user;
  final UserData? userData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(
        userData?.name ??
            user.displayName ??
            user.email ??
            AppLocalizations.of(context)!.user,
      ),
      subtitle: userData?.email != null ? Text(userData!.email!) : null,
    );
  }
}
