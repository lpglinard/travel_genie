import '../models/challenge.dart';

abstract class ChallengeRepository {
  /// Get all active challenges from the global challenges collection
  Stream<List<Challenge>> getActiveChallenges();

  /// Get a specific challenge by ID
  Future<Challenge?> getChallengeById(String challengeId);

  /// Initialize the global challenges collection with predefined challenges
  /// This should be called during app initialization or admin setup
  Future<void> initializeGlobalChallenges();

  /// Add or update a challenge in the global collection
  /// This is typically used for admin operations
  Future<void> upsertChallenge(Challenge challenge);

  /// Remove a challenge from the global collection
  /// This is typically used for admin operations
  Future<void> removeChallenge(String challengeId);

  /// Get the special create_account challenge for non-logged users
  Challenge getCreateAccountChallenge();
}
