import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../user_providers.dart';
import '../../services/auth_service.dart';

class LogoutTile extends ConsumerWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: Text(AppLocalizations.of(context)!.logout),
      onTap: () async {
        await ref.read(authServiceProvider).signOut();
        final prefs = await ref.read(preferencesServiceProvider.future);
        await prefs.clearAll();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
