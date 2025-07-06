import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import '../../providers/profile_completeness_provider.dart';
import 'error_profile_completeness.dart';
import 'loadingprofile_completeness.dart';
import 'profile_completeness_content.dart';

/// Widget that displays AI personalization information and profile completeness
/// Follows Single Responsibility Principle - only handles profile completeness display
class ProfileCompletenessWidget extends ConsumerWidget {
  const ProfileCompletenessWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileCompletenessAsync = ref.watch(profileCompletenessProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Personalization Title
          Text(
            AppLocalizations.of(context)!.aiPersonalizationTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Profile Completeness Section
          profileCompletenessAsync.when(
            loading: () => const LoadingProfileCompleteness(),
            error: (error, stack) => ErrorProfileCompleteness(error: error),
            data: (completeness) =>
                ProfileCompletenessContent(completeness: completeness),
          ),
        ],
      ),
    );
  }
}
