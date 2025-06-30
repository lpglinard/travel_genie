import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/challenge.dart';
import '../../providers/challenge_providers.dart';
import '../../core/extensions/challenge_localization_extension.dart';

class GamificationProgressSection extends ConsumerWidget {
  const GamificationProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

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
            ChallengeProgressContent(user: user),
          ],
        ),
      ),
    );
  }
}

class ChallengeProgressContent extends ConsumerWidget {
  const ChallengeProgressContent({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user == null) {
      final challengeService = ref.watch(challengeServiceProvider);
      final challenge = challengeService.getCreateAccountChallenge();
      return ChallengeItem(challenge: challenge);
    }

    final activeChallengesAsync = ref.watch(activeChallengesProvider);
    final completedChallengesAsync = ref.watch(
      completedChallengesProvider(user!.uid),
    );

    return activeChallengesAsync.when(
      data: (allChallenges) => completedChallengesAsync.when(
        data: (completedIds) {
          final totalChallenges = allChallenges.length;
          final completedCount = completedIds.length;

          final sortedChallenges = List<Challenge>.from(allChallenges)
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

          final firstUncompleted = sortedChallenges
              .where((challenge) => !completedIds.contains(challenge.id))
              .firstOrNull;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if (firstUncompleted != null)
                ChallengeItem(challenge: firstUncompleted),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class ChallengeItem extends StatelessWidget {
  const ChallengeItem({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n.challengeTitleFromKey(challenge.titleKey);
    final description = l10n.challengeDescriptionFromKey(
      challenge.descriptionKey,
    );

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
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ],
    );
  }
}
