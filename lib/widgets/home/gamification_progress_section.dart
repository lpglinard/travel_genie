import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/badge.dart' as badge_model;
import '../../models/challenge.dart';
import '../../user_providers.dart';

class GamificationProgressSection extends ConsumerWidget {
  const GamificationProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final profileService = ref.watch(profileServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).homeProgressTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<badge_model.Badge>>(
          stream: profileService.getUserBadges(user.uid),
          builder: (context, badgeSnapshot) {
            return StreamBuilder<List<Challenge>>(
              stream: profileService.getActiveChallenges(user.uid),
              builder: (context, challengeSnapshot) {
                if (badgeSnapshot.connectionState == ConnectionState.waiting ||
                    challengeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final badges = badgeSnapshot.data ?? [];
                final unlockedBadges =
                    badges.where((b) => b.isUnlocked).toList();
                final challenges = challengeSnapshot.data ?? [];

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
          },
        ),
      ],
    );
  }

  Widget _buildChallengeItem(BuildContext context, Challenge challenge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge.title,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          challenge.description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: challenge.progressPercentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            challenge.isCompleted ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }
}
