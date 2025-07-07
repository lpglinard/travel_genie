abstract class ChallengeActionsRepository {
  /// Update progress for a challenge.
  Future<void> updateProgress(
    String userId,
    String challengeId,
    int newProgress,
  );

  /// Increment progress for a challenge.
  Future<void> incrementProgress(
    String userId,
    String challengeId, {
    int increment = 1,
  });

  /// Mark a challenge as completed.
  Future<void> markCompleted(String userId, String challengeId);

  /// Reset progress for a challenge.
  Future<void> resetProgress(String userId, String challengeId);

  /// Initialize progress for a new user.
  Future<void> initializeUserProgress(String userId, List<String> challengeIds);
}
