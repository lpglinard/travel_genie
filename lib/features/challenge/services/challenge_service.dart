import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_genie/features/challenge/models/challenge.dart';

import 'challenge_repository.dart';

/// Firestore implementation for managing global challenges collection
///
/// This service handles the `/challenges/{challengeId}` collection in Firestore
/// following the new architecture where challenges are stored globally
/// and user progress is tracked separately.
class FirestoreChallengeRepository implements ChallengeRepository {
  FirestoreChallengeRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Get all active challenges from the global challenges collection
  @override
  Stream<List<Challenge>> getActiveChallenges() {
    return _firestore
        .collection('challenges')
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Challenge.fromFirestore(doc.data()))
              .toList(),
        );
  }

  /// Get a specific challenge by ID
  @override
  Future<Challenge?> getChallengeById(String challengeId) async {
    try {
      final doc = await _firestore
          .collection('challenges')
          .doc(challengeId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Challenge.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('ChallengeService: Error getting challenge $challengeId: $e');
      return null;
    }
  }

  /// Initialize the global challenges collection with predefined challenges
  /// This should be called during app initialization or admin setup
  @override
  Future<void> initializeGlobalChallenges() async {
    try {
      final batch = _firestore.batch();
      // TODO: Fix PredefinedChallenges import issue and implement initialization

      await batch.commit();
      debugPrint(
        'FirestoreChallengeRepository: Initialized global challenges collection',
      );
    } catch (e) {
      debugPrint(
        'FirestoreChallengeRepository: Error initializing global challenges: $e',
      );
      rethrow;
    }
  }

  /// Add or update a challenge in the global collection
  /// This is typically used for admin operations
  @override
  Future<void> upsertChallenge(Challenge challenge) async {
    try {
      await _firestore
          .collection('challenges')
          .doc(challenge.id)
          .set(challenge.toFirestore());

      debugPrint('ChallengeService: Upserted challenge ${challenge.id}');
    } catch (e) {
      debugPrint(
        'ChallengeService: Error upserting challenge ${challenge.id}: $e',
      );
      rethrow;
    }
  }

  /// Remove a challenge from the global collection
  /// This is typically used for admin operations
  @override
  Future<void> removeChallenge(String challengeId) async {
    try {
      await _firestore.collection('challenges').doc(challengeId).delete();

      debugPrint('ChallengeService: Removed challenge $challengeId');
    } catch (e) {
      debugPrint('ChallengeService: Error removing challenge $challengeId: $e');
      rethrow;
    }
  }

  /// Get the special create_account challenge for non-logged users
  @override
  Challenge getCreateAccountChallenge() {
    return const Challenge(
      id: "create_account",
      titleKey: "challengeCreateAccountTitle",
      descriptionKey: "challengeCreateAccountDescription",
      goal: 1,
      type: "create_account",
      isActive: true,
      endDate: 9999999999999,
      displayOrder: 1,
      rewardType: "badge",
      rewardValue: "starter_badge",
    );
  }
}
