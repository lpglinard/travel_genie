import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/features/user/services/profile_completeness_service.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

/// Content for profile completeness with actual data
/// Follows Single Responsibility Principle - only handles profile completeness content display
class ProfileCompletenessContent extends StatelessWidget {
  const ProfileCompletenessContent({super.key, required this.completeness});

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
