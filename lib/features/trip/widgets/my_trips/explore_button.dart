import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

/// Widget that displays the explore button
class ExploreButton extends StatelessWidget {
  const ExploreButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigate to explore page
        context.go('/explore');
      },
      icon: const Icon(Icons.search),
      label: Text(AppLocalizations.of(context)!.exploreDestinations),
    );
  }
}
