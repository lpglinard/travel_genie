import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/challenge.dart';
import '../../providers/challenge_providers.dart';
import '../../services/auth_service.dart';

class GamificationProgressSection extends ConsumerWidget {
  const GamificationProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;

    return InkWell(
      onTap: () => context.go('/profile'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).homeProgressTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildChallengeProgress(context, ref, user),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeProgress(
    BuildContext context,
    WidgetRef ref,
    User? user,
  ) {
    // For non-logged users, show only the create_account challenge
    if (user == null) {
      final challengeService = ref.watch(challengeServiceProvider);
      final createAccountChallenge = challengeService
          .getCreateAccountChallenge();
      return _buildChallengeItem(context, createAccountChallenge);
    }

    // For logged users, show challenge progress from challengeProgress collection
    final activeChallengesAsync = ref.watch(activeChallengesProvider);
    final completedChallengesAsync = ref.watch(
      completedChallengesProvider(user.uid),
    );

    return activeChallengesAsync.when(
      data: (allChallenges) {
        return completedChallengesAsync.when(
          data: (completedChallengeIds) {
            final totalChallenges = allChallenges.length;
            final completedCount = completedChallengeIds.length;

            // Find first uncompleted challenge (sorted by displayOrder)
            final sortedChallenges = List<Challenge>.from(allChallenges)
              ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

            final firstUncompletedChallenge = sortedChallenges
                .where(
                  (challenge) => !completedChallengeIds.contains(challenge.id),
                )
                .firstOrNull;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Challenge progress
                Text(
                  AppLocalizations.of(
                    context,
                  ).unlockedBadges(completedCount, totalChallenges),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: totalChallenges > 0
                      ? completedCount / totalChallenges
                      : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 12),
                // First uncompleted challenge
                if (firstUncompletedChallenge != null)
                  _buildChallengeItem(context, firstUncompletedChallenge),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildChallengeItem(BuildContext context, Challenge challenge) {
    final l10n = AppLocalizations.of(context);

    // Get localized title and description
    String title;
    String description;

    try {
      // Use reflection-like approach to get localized strings
      switch (challenge.titleKey) {
        case 'challengeCreateAccountTitle':
          title = l10n.challengeCreateAccountTitle;
          break;
        case 'challengeCompleteProfileTitle':
          title = l10n.challengeCompleteProfileTitle;
          break;
        case 'challengeCreateTripTitle':
          title = l10n.challengeCreateTripTitle;
          break;
        case 'challengeSavePlaceTitle':
          title = l10n.challengeSavePlaceTitle;
          break;
        case 'challengeGenerateItineraryTitle':
          title = l10n.challengeGenerateItineraryTitle;
          break;
        default:
          title = challenge.titleKey; // Fallback to key
      }

      switch (challenge.descriptionKey) {
        case 'challengeCreateAccountDescription':
          description = l10n.challengeCreateAccountDescription;
          break;
        case 'challengeCompleteProfileDescription':
          description = l10n.challengeCompleteProfileDescription;
          break;
        case 'challengeCreateTripDescription':
          description = l10n.challengeCreateTripDescription;
          break;
        case 'challengeSavePlaceDescription':
          description = l10n.challengeSavePlaceDescription;
          break;
        case 'challengeGenerateItineraryDescription':
          description = l10n.challengeGenerateItineraryDescription;
          break;
        default:
          description = challenge.descriptionKey; // Fallback to key
      }
    } catch (e) {
      // Fallback to the keys if localization fails
      title = challenge.titleKey;
      description = challenge.descriptionKey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.0,
          // For display purposes only, actual progress is handled separately
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ],
    );
  }
}
