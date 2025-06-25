import 'package:flutter/material.dart';

import '../models/badge.dart' as badge_model;
import '../models/challenge.dart';
import '../models/travel_cover.dart';
import 'firestore_service.dart';

class ProfileService {
  ProfileService(this._firestoreService);

  final FirestoreService _firestoreService;

  /// Get user badges
  Stream<List<badge_model.Badge>> getUserBadges(String userId) {
    return _firestoreService.getUserBadges(userId).asyncMap((badges) async {
      // If badges list is empty, initialize user profile
      if (badges.isEmpty) {
        debugPrint('ProfileService: No badges found for user $userId, initializing profile...');
        await initializeUserProfile(userId);
        // Return the badges again after initialization
        return await _firestoreService.getUserBadges(userId).first;
      }
      return badges;
    });
  }

  /// Get user travel cover collection
  Stream<TravelCoverCollection?> getUserTravelCovers(String userId) {
    return _firestoreService.getUserTravelCovers(userId);
  }

  /// Get active challenges for user
  Stream<List<Challenge>> getActiveChallenges(String userId) {
    return _firestoreService.getActiveChallenges(userId);
  }

  /// Get user's challenge progress
  Stream<Map<String, int>> getUserChallengeProgress(String userId) {
    return _firestoreService.getUserChallengeProgress(userId);
  }

  /// Initialize user profile with default badges and challenges
  Future<void> initializeUserProfile(String userId) async {
    return _firestoreService.initializeUserProfile(userId);
  }

  /// Unlock a badge for the user
  Future<void> unlockBadge(String userId, String badgeId) async {
    return _firestoreService.unlockBadge(userId, badgeId);
  }

  /// Add a travel cover to user's collection
  Future<void> addTravelCover(String userId, TravelCover cover) async {
    return _firestoreService.addTravelCover(userId, cover);
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress(String userId, String challengeId, int progress) async {
    return _firestoreService.updateChallengeProgress(userId, challengeId, progress);
  }

  /// Check and trigger achievements based on user actions
  Future<void> checkAchievements(String userId, AchievementTrigger trigger, {Map<String, dynamic>? data}) async {
    switch (trigger) {
      case AchievementTrigger.firstTrip:
        await unlockBadge(userId, 'first_trip');
        break;
      case AchievementTrigger.firstLogin:
        await unlockBadge(userId, 'first_login');
        break;
      case AchievementTrigger.firstInvite:
        await unlockBadge(userId, 'first_invite');
        break;
      case AchievementTrigger.firstAiCover:
        await unlockBadge(userId, 'first_ai_cover');
        break;
      case AchievementTrigger.tripCreated:
        await _updateTripChallenges(userId);
        break;
      case AchievementTrigger.placeAdded:
        await _updatePlaceChallenges(userId, data?['placeCount'] as int? ?? 1);
        break;
      case AchievementTrigger.friendInvited:
        await _updateInviteChallenges(userId);
        break;
      case AchievementTrigger.coverGenerated:
        await _updateCoverChallenges(userId, data?['coverStyle'] as String?);
        break;
    }
  }

  Future<void> _updateTripChallenges(String userId) async {
    final activeChallenges = await getActiveChallenges(userId).first;
    final tripChallenges = activeChallenges.where((c) => c.type == ChallengeType.createTrips);

    for (final challenge in tripChallenges) {
      final currentProgress = await _getChallengeProgress(userId, challenge.id);
      await updateChallengeProgress(userId, challenge.id, currentProgress + 1);
    }
  }

  Future<void> _updatePlaceChallenges(String userId, int placeCount) async {
    final activeChallenges = await getActiveChallenges(userId).first;
    final placeChallenges = activeChallenges.where((c) => c.type == ChallengeType.addPlaces);

    for (final challenge in placeChallenges) {
      final currentProgress = await _getChallengeProgress(userId, challenge.id);
      await updateChallengeProgress(userId, challenge.id, currentProgress + placeCount);
    }
  }

  Future<void> _updateInviteChallenges(String userId) async {
    final activeChallenges = await getActiveChallenges(userId).first;
    final inviteChallenges = activeChallenges.where((c) => c.type == ChallengeType.inviteFriends);

    for (final challenge in inviteChallenges) {
      final currentProgress = await _getChallengeProgress(userId, challenge.id);
      await updateChallengeProgress(userId, challenge.id, currentProgress + 1);
    }
  }

  Future<void> _updateCoverChallenges(String userId, String? coverStyle) async {
    final activeChallenges = await getActiveChallenges(userId).first;
    final coverChallenges = activeChallenges.where((c) => c.type == ChallengeType.generateCovers);

    for (final challenge in coverChallenges) {
      final currentProgress = await _getChallengeProgress(userId, challenge.id);
      await updateChallengeProgress(userId, challenge.id, currentProgress + 1);
    }

    // Add the generated cover to user's collection if style is provided
    if (coverStyle != null) {
      final coverStyleEnum = CoverStyle.values.firstWhere(
        (style) => style.name == coverStyle,
        orElse: () => CoverStyle.impressionist,
      );

      final newCover = TravelCover(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tripId: '', // This should be provided from the calling context
        imageUrl: '', // This should be provided from the calling context
        style: coverStyleEnum,
        createdAt: DateTime.now(),
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      await addTravelCover(userId, newCover);
    }
  }

  Future<int> _getChallengeProgress(String userId, String challengeId) async {
    return _firestoreService.getChallengeProgress(userId, challengeId);
  }

  /// Get user profile statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final badges = await getUserBadges(userId).first;
    final covers = await getUserTravelCovers(userId).first;
    final challengeProgress = await getUserChallengeProgress(userId).first;

    final unlockedBadges = badges.where((badge) => badge.isUnlocked).length;
    final totalBadges = badges.length;
    final unlockedCovers = covers?.totalUnlocked ?? 0;
    final totalCovers = covers?.covers.length ?? 0;
    final activeChallenges = challengeProgress.length;

    return {
      'unlockedBadges': unlockedBadges,
      'totalBadges': totalBadges,
      'unlockedCovers': unlockedCovers,
      'totalCovers': totalCovers,
      'activeChallenges': activeChallenges,
      'badgeCompletionPercentage': totalBadges > 0 ? (unlockedBadges / totalBadges) * 100 : 0.0,
      'coverCompletionPercentage': covers?.completionPercentage ?? 0.0,
    };
  }
}

enum AchievementTrigger {
  firstTrip,
  firstLogin,
  firstInvite,
  firstAiCover,
  tripCreated,
  placeAdded,
  friendInvited,
  coverGenerated,
}
