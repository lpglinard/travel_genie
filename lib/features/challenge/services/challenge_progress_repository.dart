abstract class ChallengeProgressRepository {
  /// Get user's progress for all challenges
  Stream<Map<String, int>> getUserChallengeProgress(String userId);

  /// Get user's progress for a specific challenge
  Future<int> getChallengeProgress(String userId, String challengeId);

  /// Update user's progress for a specific challenge
  Future<void> updateChallengeProgress(
    String userId,
    String challengeId,
    int newProgress,
  );

  /// Increment user's progress for a specific challenge
  Future<void> incrementChallengeProgress(
    String userId,
    String challengeId, {
    int increment = 1,
  });

  /// Initialize user's challenge progress for all active challenges
  /// This should be called when a user first registers or when new challenges are added
  Future<void> initializeUserChallengeProgress(
    String userId,
    List<String> challengeIds,
  );

  /// Mark a challenge as completed for a user
  Future<void> markChallengeCompleted(String userId, String challengeId);

  /// Get completed challenges for a user
  Stream<List<String>> getCompletedChallenges(String userId);

  /// Reset user's progress for a specific challenge
  Future<void> resetChallengeProgress(String userId, String challengeId);

  /// Delete all challenge progress for a user (used when deleting user account)
  Future<void> deleteUserChallengeProgress(String userId);
}
