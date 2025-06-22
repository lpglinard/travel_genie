import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/user_providers.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return AppBar(
      title: Text(
        AppLocalizations.of(context).navHome,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            authState.whenData((user) {
              if (user != null && !user.isAnonymous) {
                // Navigate to profile screen if user is authenticated and not anonymous
                context.push('/profile');
              } else {
                // Navigate to sign-in screen if user is anonymous
                context.go('/signin');
              }
            });
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
