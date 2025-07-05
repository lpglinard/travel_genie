import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/services/profile_completeness_service.dart';

import '../providers/profile_completeness_provider.dart';

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
            loading: () => const _LoadingProfileCompleteness(),
            error: (error, stack) => _ErrorProfileCompleteness(error: error),
            data: (completeness) =>
                _ProfileCompletenessContent(completeness: completeness),
          ),
        ],
      ),
    );
  }
}

/// Loading state for profile completeness
class _LoadingProfileCompleteness extends StatelessWidget {
  const _LoadingProfileCompleteness();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shimmer effect for progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        // Shimmer effect for text
        Container(
          height: 16,
          width: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        // Shimmer effect for button
        Container(
          height: 36,
          width: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ],
    );
  }
}

/// Error state for profile completeness
class _ErrorProfileCompleteness extends StatelessWidget {
  const _ErrorProfileCompleteness({required this.error});

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

/// Content for profile completeness with actual data
class _ProfileCompletenessContent extends StatelessWidget {
  const _ProfileCompletenessContent({required this.completeness});

  final ProfileCompletenessInfo completeness;

  @override
  Widget build(BuildContext context) {
    final progressColor = _getProgressColor(completeness.percentageAsInt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: completeness.percentage,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
        const SizedBox(height: 8),

        // Percentage Text
        Text(
          AppLocalizations.of(
            context,
          )!.profileCompleteness(completeness.percentageAsInt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 12),

        // Improve/Change Profile Button
        OutlinedButton.icon(
          onPressed: () => context.push('/traveler-profile'),
          icon: const Icon(Icons.person, size: 18),
          label: Text(
            completeness.isComplete
                ? AppLocalizations.of(context)!.changeMyProfile
                : AppLocalizations.of(context)!.improveMyProfile,
          ),
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

  Color _getProgressColor(int percentage) {
    if (percentage >= 80) {
      return Colors.green.shade400;
    } else if (percentage >= 60) {
      return Colors.lightBlue.shade400;
    } else if (percentage >= 40) {
      return Colors.orange.shade400;
    } else {
      return Colors.red.shade400;
    }
  }
}
