import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for managing user challenge progress
/// 
/// This service handles the `/users/{userId}/challengeProgress/{challengeId}` 
/// collection in Firestore following the new architecture where user progress
/// is tracked separately from the global challenges.
class ChallengeProgressService {
  ChallengeProgressService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Get user's progress for all challenges
  Stream<Map<String, int>> getUserChallengeProgress(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('challengeProgress')
        .snapshots()
        .map((snapshot) {
      final progressMap = <String, int>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        progressMap[doc.id] = data['progress'] as int? ?? 0;
      }
      return progressMap;
    });
  }

  /// Get user's progress for a specific challenge
  Future<int> getChallengeProgress(String userId, String challengeId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challengeProgress')
          .doc(challengeId)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['progress'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('ChallengeProgressService: Error getting progress for $challengeId: $e');
      return 0;
    }
  }

  /// Update user's progress for a specific challenge
  Future<void> updateChallengeProgress(
    String userId,
    String challengeId,
    int newProgress,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('challengeProgress')
          .doc(challengeId)
          .set({
        'progress': newProgress,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('ChallengeProgressService: Updated progress for $challengeId to $newProgress');
    } catch (e) {
      debugPrint('ChallengeProgressService: Error updating progress for $challengeId: $e');
      rethrow;
    }
  }

  /// Increment user's progress for a specific challenge
  Future<void> incrementChallengeProgress(
    String userId,
    String challengeId, {
    int increment = 1,
  }) async {
    try {
      final currentProgress = await getChallengeProgress(userId, challengeId);
      await updateChallengeProgress(userId, challengeId, currentProgress + increment);
    } catch (e) {
      debugPrint('ChallengeProgressService: Error incrementing progress for $challengeId: $e');
      rethrow;
    }
  }

  /// Initialize user's challenge progress for all active challenges
  /// This should be called when a user first registers or when new challenges are added
  Future<void> initializeUserChallengeProgress(
    String userId,
    List<String> challengeIds,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final challengeId in challengeIds) {
        final progressRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('challengeProgress')
            .doc(challengeId);

        batch.set(progressRef, {
          'progress': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('ChallengeProgressService: Initialized progress for user $userId');
    } catch (e) {
      debugPrint('ChallengeProgressService: Error initializing progress for user $userId: $e');
      rethrow;
    }
  }

  /// Mark a challenge as completed for a user
  Future<void> markChallengeCompleted(
    String userId,
    String challengeId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('challengeProgress')
          .doc(challengeId)
          .update({
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('ChallengeProgressService: Marked challenge $challengeId as completed for user $userId');
    } catch (e) {
      debugPrint('ChallengeProgressService: Error marking challenge $challengeId as completed: $e');
      rethrow;
    }
  }

  /// Get completed challenges for a user
  Stream<List<String>> getCompletedChallenges(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('challengeProgress')
        .where('completed', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Reset user's progress for a specific challenge
  Future<void> resetChallengeProgress(String userId, String challengeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('challengeProgress')
          .doc(challengeId)
          .update({
        'progress': 0,
        'completed': false,
        'completedAt': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('ChallengeProgressService: Reset progress for challenge $challengeId');
    } catch (e) {
      debugPrint('ChallengeProgressService: Error resetting progress for $challengeId: $e');
      rethrow;
    }
  }

  /// Delete all challenge progress for a user (used when deleting user account)
  Future<void> deleteUserChallengeProgress(String userId) async {
    try {
      final batch = _firestore.batch();
      final progressDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challengeProgress')
          .get();

      for (final doc in progressDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('ChallengeProgressService: Deleted all progress for user $userId');
    } catch (e) {
      debugPrint('ChallengeProgressService: Error deleting progress for user $userId: $e');
      rethrow;
    }
  }
}
