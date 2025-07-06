import 'package:flutter/foundation.dart';
import 'package:travel_genie/core/services/analytics_service.dart';

import 'challenge_actions_repository.dart';
import 'challenge_progress_repository.dart';

/// Firestore implementation providing actions for managing challenge progress.
class FirestoreChallengeActionsRepository implements ChallengeActionsRepository {
  FirestoreChallengeActionsRepository(this._progressRepository, this._analyticsService);

  final ChallengeProgressRepository _progressRepository;
  final AnalyticsService _analyticsService;

  /// Update progress for a challenge.
  @override
  Future<void> updateProgress(
    String userId,
    String challengeId,
    int newProgress,
  ) async {
    await _progressRepository.updateChallengeProgress(
      userId,
      challengeId,
      newProgress,
    );
  }

  /// Increment progress for a challenge.
  @override
  Future<void> incrementProgress(
    String userId,
    String challengeId, {
    int increment = 1,
  }) async {
    await _progressRepository.incrementChallengeProgress(
      userId,
      challengeId,
      increment: increment,
    );
  }

  /// Mark a challenge as completed.
  @override
  Future<void> markCompleted(String userId, String challengeId) async {
    await _progressRepository.markChallengeCompleted(userId, challengeId);

    // Log the achievement unlock to analytics
    try {
      await _analyticsService.logUnlockAchievement(achievementId: challengeId);
    } catch (e) {
      // Log error but don't prevent the challenge completion flow
      debugPrint('Error logging challenge completion to analytics: $e');
    }
  }

  /// Reset progress for a challenge.
  @override
  Future<void> resetProgress(String userId, String challengeId) async {
    await _progressRepository.resetChallengeProgress(userId, challengeId);
  }

  /// Initialize progress for a new user.
  @override
  Future<void> initializeUserProgress(
    String userId,
    List<String> challengeIds,
  ) async {
    await _progressRepository.initializeUserChallengeProgress(
      userId,
      challengeIds,
    );
  }
}
