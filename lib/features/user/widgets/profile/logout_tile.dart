import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/core/providers/infrastructure_providers.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

class LogoutTile extends ConsumerWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
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
    );
  }
}
