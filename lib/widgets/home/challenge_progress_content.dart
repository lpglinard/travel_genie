import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/challenge.dart';
import '../../providers/challenge_providers.dart';
import '../login_required_dialog.dart';
import 'challenge_item.dart';

class ChallengeProgressContent extends ConsumerWidget {
  const ChallengeProgressContent({super.key, required this.user});

  final User? user;

  /// Generate appropriate onTap callback based on challenge type
  VoidCallback? _getOnTapCallback(BuildContext context, Challenge challenge) {
    switch (challenge.type) {
      case 'create_account':
        return () async {
          await LoginRequiredDialog.show(context);
        };
      case 'complete_profile':
        return () {
          context.go('/profile');
        };
      case 'create_trip':
        return () {
          context.go('/new-trip');
        };
      case 'save_place':
        return () {
          // Navigate to explore page where users can find and save places
          context.go('/explore');
        };
      case 'generate_itinerary':
        return () {
          // Navigate to create trip page where users can generate itineraries
          context.go('/new-trip');
        };
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user == null) {
      final challengeService = ref.watch(challengeServiceProvider);
      final challenge = challengeService.getCreateAccountChallenge();
      return ChallengeItem(
        challenge: challenge,
        onTap: _getOnTapCallback(context, challenge),
      );
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
                ChallengeItem(
                  challenge: firstUncompleted,
                  onTap: _getOnTapCallback(context, firstUncompleted),
                ),
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
