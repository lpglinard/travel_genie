import 'analytics_service.dart';
import 'challenge_progress_service.dart';

/// Service providing actions for managing challenge progress.
class ChallengeActionsService {
  ChallengeActionsService(this._progressService, this._analyticsService);

  final ChallengeProgressService _progressService;
  final AnalyticsService _analyticsService;

  /// Update progress for a challenge.
  Future<void> updateProgress(
    String userId,
    String challengeId,
    int newProgress,
  ) async {
    await _progressService.updateChallengeProgress(
      userId,
      challengeId,
      newProgress,
    );
  }

  /// Increment progress for a challenge.
  Future<void> incrementProgress(
    String userId,
    String challengeId, {
    int increment = 1,
  }) async {
    await _progressService.incrementChallengeProgress(
      userId,
      challengeId,
      increment: increment,
    );
  }

  /// Mark a challenge as completed.
  Future<void> markCompleted(String userId, String challengeId) async {
    await _progressService.markChallengeCompleted(userId, challengeId);

    // Log the achievement unlock to analytics
    try {
      await _analyticsService.logUnlockAchievement(
        achievementId: challengeId,
      );
    } catch (e) {
      // Log error but don't prevent the challenge completion flow
      print('Error logging challenge completion to analytics: $e');
    }
  }

  /// Reset progress for a challenge.
  Future<void> resetProgress(String userId, String challengeId) async {
    await _progressService.resetChallengeProgress(userId, challengeId);
  }

  /// Initialize progress for a new user.
  Future<void> initializeUserProgress(
    String userId,
    List<String> challengeIds,
  ) async {
    await _progressService.initializeUserChallengeProgress(
      userId,
      challengeIds,
    );
  }
}
