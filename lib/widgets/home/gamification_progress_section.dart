import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/badge.dart' as badge_model;
import '../../models/challenge.dart';
import '../../providers/challenge_providers.dart';
import '../../user_providers.dart';

class GamificationProgressSection extends ConsumerWidget {
  const GamificationProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final challengesAsync = ref.watch(userChallengesWithProgressProvider);

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
            challengesAsync.when(
              data: (challenges) {
                // For logged users, show badges and challenges
                if (user != null) {
                  final profileService = ref.watch(profileServiceProvider);
                  return StreamBuilder<List<badge_model.Badge>>(
                    stream: profileService.getUserBadges(user.uid),
                    builder: (context, badgeSnapshot) {
                      final badges = badgeSnapshot.data ?? [];
                      final unlockedBadges = badges.where((b) => b.isUnlocked).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (badges.isNotEmpty) ...[
                            Text(
                              AppLocalizations.of(context)
                                  .unlockedBadges(unlockedBadges.length, badges.length),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: badges.isNotEmpty
                                  ? unlockedBadges.length / badges.length
                                  : 0,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (challenges.isNotEmpty)
                            _buildChallengeItem(context, challenges.first),
                        ],
                      );
                    },
                  );
                } else {
                  // For non-logged users, show only the create_account challenge
                  if (challenges.isNotEmpty) {
                    return _buildChallengeItem(context, challenges.first);
                  }
                  return const SizedBox.shrink();
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
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
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.0, // For display purposes only, actual progress is handled separately
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ],
    );
  }
}
