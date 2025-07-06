import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

/// Error state for profile completeness
/// Follows Single Responsibility Principle - only handles error state display
class ErrorProfileCompleteness extends StatelessWidget {
  const ErrorProfileCompleteness({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Default progress bar (50%)
        LinearProgressIndicator(
          value: 0.5,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.profileCompleteness(50),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/traveler-profile'),
          icon: const Icon(Icons.person, size: 18),
          label: Text(AppLocalizations.of(context)!.improveMyProfile),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5B6EFF),
            side: const BorderSide(color: Color(0xFF5B6EFF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
