import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:travel_genie/services/profile_service.dart';
import 'package:travel_genie/models/badge.dart' as badge_model;

void main() {
  group('ProfileService', () {
    late ProfileService profileService;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      profileService = ProfileService(fakeFirestore);
    });

    test('should initialize user profile with default badges', () async {
      const userId = 'test_user_123';
      
      // Initialize user profile
      await profileService.initializeUserProfile(userId);
      
      // Verify badges were created
      final badgesSnapshot = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .get();
      
      expect(badgesSnapshot.docs.length, equals(badge_model.PredefinedBadges.allBadges.length));
      
      // Verify first badge exists and is not unlocked by default
      final firstBadgeDoc = badgesSnapshot.docs.first;
      final badgeData = firstBadgeDoc.data();
      expect(badgeData['isUnlocked'], equals(false));
      expect(badgeData['name'], isNotNull);
      expect(badgeData['description'], isNotNull);
    });

    test('should unlock a badge for user', () async {
      const userId = 'test_user_123';
      const badgeId = 'first_trip';
      
      // Initialize user profile first
      await profileService.initializeUserProfile(userId);
      
      // Unlock the badge
      await profileService.unlockBadge(userId, badgeId);
      
      // Verify badge is unlocked
      final badgeDoc = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc(badgeId)
          .get();
      
      final badgeData = badgeDoc.data()!;
      expect(badgeData['isUnlocked'], equals(true));
      expect(badgeData['unlockedAt'], isNotNull);
    });

    test('should get user badges stream', () async {
      const userId = 'test_user_123';
      
      // Initialize user profile
      await profileService.initializeUserProfile(userId);
      
      // Get badges stream
      final badgesStream = profileService.getUserBadges(userId);
      final badges = await badgesStream.first;
      
      expect(badges.length, equals(badge_model.PredefinedBadges.allBadges.length));
      expect(badges.first.name, isNotEmpty);
      expect(badges.first.description, isNotEmpty);
      expect(badges.first.isUnlocked, equals(false));
    });
  });
}