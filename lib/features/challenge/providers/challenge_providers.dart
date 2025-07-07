import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/infrastructure_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../user/providers/user_providers.dart';
import '../models/challenge.dart';
import '../services/challenge_actions_repository.dart';
import '../services/challenge_actions_service.dart';
import '../services/challenge_progress_repository.dart';
import '../services/challenge_progress_service.dart';
import '../services/challenge_repository.dart';
import '../services/challenge_service.dart';

/// Challenge actions provider
final challengeActionsProvider = Provider<ChallengeActionsRepository>((ref) {
  final progressRepository = ref.watch(challengeProgressRepositoryProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return FirestoreChallengeActionsRepository(
    progressRepository,
    analyticsService,
  );
});

/// Provider for active challenges from the global collection
final activeChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  return challengeRepository.getActiveChallenges();
});

/// Provider for user challenge progress
final userChallengeProgressProvider =
    StreamProvider.family<Map<String, int>, String>((ref, userId) {
      final progressRepository = ref.watch(challengeProgressRepositoryProvider);
      return progressRepository.getUserChallengeProgress(userId);
    });

/// Provider for completed challenges for a user
final completedChallengesProvider = StreamProvider.family<List<String>, String>(
  (ref, userId) {
    final progressRepository = ref.watch(challengeProgressRepositoryProvider);
    return progressRepository.getCompletedChallenges(userId);
  },
);

/// Provider that combines challenges with user progress
/// This is the main provider that UI components should use
final userChallengesWithProgressProvider = StreamProvider<List<Challenge>>((
  ref,
) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);

  // Watch auth state changes to ensure data is cleared when user logs out
  return ref
      .watch(authStateChangesProvider)
      .when(
        data: (user) {
          // For non-logged users, return only the create_account challenge
          if (user == null) {
            final createAccountChallenge = challengeRepository
                .getCreateAccountChallenge();
            return Stream.value([createAccountChallenge]);
          }

          // For logged users, combine challenges with their progress
          return challengeRepository.getActiveChallenges();
        },
        loading: () {
          final createAccountChallenge = challengeRepository
              .getCreateAccountChallenge();
          return Stream.value([createAccountChallenge]);
        },
        error: (_, _) {
          final createAccountChallenge = challengeRepository
              .getCreateAccountChallenge();
          return Stream.value([createAccountChallenge]);
        },
      );
});

/// Provider for a specific challenge with user progress
final challengeWithProgressProvider = StreamProvider.family<Challenge?, String>(
  (ref, challengeId) {
    final challengeRepository = ref.watch(challengeRepositoryProvider);

    // Watch auth state changes to ensure data is cleared when user logs out
    return ref
        .watch(authStateChangesProvider)
        .when(
          data: (user) {
            // For non-logged users, only return create_account challenge
            if (user == null) {
              if (challengeId == "create_account") {
                return Stream.value(
                  challengeRepository.getCreateAccountChallenge(),
                );
              }
              return Stream.value(null);
            }

            // For logged users, get challenge and combine with progress
            return challengeRepository.getActiveChallenges().map((challenges) {
              return challenges.where((c) => c.id == challengeId).firstOrNull;
            });
          },
          loading: () {
            if (challengeId == "create_account") {
              return Stream.value(
                challengeRepository.getCreateAccountChallenge(),
              );
            }
            return Stream.value(null);
          },
          error: (_, _) {
            if (challengeId == "create_account") {
              return Stream.value(
                challengeRepository.getCreateAccountChallenge(),
              );
            }
            return Stream.value(null);
          },
        );
  },
);
