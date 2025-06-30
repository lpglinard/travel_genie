import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge.dart';
import '../services/challenge_actions_service.dart';
import '../services/challenge_progress_service.dart';
import '../services/challenge_service.dart';

/// Provider for ChallengeService
final challengeServiceProvider = Provider<ChallengeService>((ref) {
  return ChallengeService(FirebaseFirestore.instance);
});

/// Provider for ChallengeProgressService
final challengeProgressServiceProvider = Provider<ChallengeProgressService>((
  ref,
) {
  return ChallengeProgressService(FirebaseFirestore.instance);
});

/// Provider for active challenges from the global collection
final activeChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final challengeService = ref.watch(challengeServiceProvider);
  return challengeService.getActiveChallenges();
});

/// Provider for user challenge progress
final userChallengeProgressProvider =
    StreamProvider.family<Map<String, int>, String>((ref, userId) {
      final progressService = ref.watch(challengeProgressServiceProvider);
      return progressService.getUserChallengeProgress(userId);
    });

/// Provider for completed challenges for a user
final completedChallengesProvider = StreamProvider.family<List<String>, String>(
  (ref, userId) {
    final progressService = ref.watch(challengeProgressServiceProvider);
    return progressService.getCompletedChallenges(userId);
  },
);

/// Provider that combines challenges with user progress
/// This is the main provider that UI components should use
final userChallengesWithProgressProvider = StreamProvider<List<Challenge>>((
  ref,
) {
  final user = FirebaseAuth.instance.currentUser;

  // For non-logged users, return only the create_account challenge
  if (user == null) {
    final challengeService = ref.watch(challengeServiceProvider);
    final createAccountChallenge = challengeService.getCreateAccountChallenge();
    return Stream.value([createAccountChallenge]);
  }

  // For logged users, combine challenges with their progress
  final challengeService = ref.watch(challengeServiceProvider);
  final progressService = ref.watch(challengeProgressServiceProvider);

  return challengeService.getActiveChallenges();
});

/// Provider for a specific challenge with user progress
final challengeWithProgressProvider = StreamProvider.family<Challenge?, String>(
  (ref, challengeId) {
    final user = FirebaseAuth.instance.currentUser;

    // For non-logged users, only return create_account challenge
    if (user == null) {
      if (challengeId == "create_account") {
        final challengeService = ref.watch(challengeServiceProvider);
        return Stream.value(challengeService.getCreateAccountChallenge());
      }
      return Stream.value(null);
    }

    // For logged users, get challenge and combine with progress
    final challengeService = ref.watch(challengeServiceProvider);
    final progressService = ref.watch(challengeProgressServiceProvider);

    return challengeService.getActiveChallenges().map((challenges) {
      return challenges.where((c) => c.id == challengeId).firstOrNull;
    });
  },
);

/// Provider for challenge actions (updating progress, marking complete, etc.)
final challengeActionsProvider = Provider<ChallengeActionsService>((ref) {
  final progressService = ref.watch(challengeProgressServiceProvider);
  return ChallengeActionsService(progressService);
});
