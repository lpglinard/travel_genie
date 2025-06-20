import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/user_providers.dart';

class GreetingSection extends ConsumerWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final userData = ref.watch(userDataProvider).valueOrNull;
    String greeting = AppLocalizations.of(context).greeting;

    authState.whenData((user) {
      if (user != null && !user.isAnonymous) {
        final name = userData?.name ?? user.displayName;
        if (name != null && name.isNotEmpty) {
          greeting = '${AppLocalizations.of(context).greeting}, $name';
        }
      }
    });

    return Text(
      greeting, 
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
