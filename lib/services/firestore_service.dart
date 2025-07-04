import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/badge.dart' as badge_model;
import '../models/challenge.dart';
import '../models/destination.dart';
import '../models/itinerary_day.dart';
import '../models/location.dart';
import '../models/photo.dart';
import '../models/place.dart';
import '../models/travel_cover.dart';
import '../models/traveler_profile.dart';
import '../models/trip.dart';
import '../models/user_data.dart';

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  // ============================================================================
  // PRIVATE COLLECTION REFERENCES
  // ============================================================================

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _trips =>
      _firestore.collection('trips');

  CollectionReference<Map<String, dynamic>> get _groupsFeedback =>
      _firestore.collection('groups_feedback');

  CollectionReference<Map<String, dynamic>> _savedPlacesCollection(
    String userId,
  ) {
    return _users.doc(userId).collection('saved_places');
  }

  // ============================================================================
  // USER MANAGEMENT
  // ============================================================================

  Stream<UserData> streamUser(String uid) {
    return _users.doc(uid).snapshots().map(UserData.fromDoc);
  }

  Future<void> upsertUser(User user, {Locale? locale, bool? darkMode}) {
    final doc = _users.doc(user.uid);
    final data = <String, dynamic>{
      'name': user.displayName,
      'email': user.email,
    };
    // Always update locale field when provided, even if null (for Portuguese)
    if (locale != null) {
      data['locale'] = locale.languageCode;
    } else {
      // Explicitly set locale to null for Portuguese (default language)
      data['locale'] = null;
    }
    if (darkMode != null) {
      data['darkMode'] = darkMode;
    }
    return doc.set(data, SetOptions(merge: true));
  }

  // ============================================================================
  // SAVED PLACES MANAGEMENT
  // ============================================================================

  Future<void> savePlace(String userId, Place place) async {
    // Check if placeId is empty to avoid Firestore error
    if (place.placeId.isEmpty) {
      print('Warning: Attempted to save a place with empty placeId');
      return;
    }

    final savedPlacesRef = _savedPlacesCollection(userId);
    String? reference;
    if (place.photos.isNotEmpty && place.photos.first.reference.isNotEmpty) {
      reference = place.photos.first.reference;
    }
    await savedPlacesRef.doc(place.placeId).set({
      'placeId': place.placeId,
      'name': place.displayName,
      'reference': reference,
      'savedDate': FieldValue.serverTimestamp(),
      'address': place.formattedAddress,
      'types': place.types,
      'rating': place.rating,
    });
  }

  Future<void> removePlace(String userId, String placeId) async {
    // Check if placeId is empty to avoid Firestore error
    if (placeId.isEmpty) {
      print('Warning: Attempted to remove a place with empty placeId');
      return;
    }
    await _savedPlacesCollection(userId).doc(placeId).delete();
  }

  Future<bool> isPlaceSaved(String userId, String placeId) async {
    // Check if placeId is empty to avoid Firestore error
    if (placeId.isEmpty) {
      print(
        'Warning: Attempted to check if a place with empty placeId is saved',
      );
      return false;
    }
    final docSnapshot = await _savedPlacesCollection(userId).doc(placeId).get();
    return docSnapshot.exists;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSavedPlaces(String userId) {
    return _savedPlacesCollection(
      userId,
    ).orderBy('savedDate', descending: true).snapshots();
  }

  Stream<List<Place>> streamSavedPlacesAsPlaces(String userId) {
    return streamSavedPlaces(userId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        String? reference;
        if (data['reference'] != null) {
          reference = data['reference'] as String?;
        }

        return Place(
          placeId: data['placeId'] as String? ?? '',
          displayName: data['name'] as String? ?? '',
          displayNameLanguageCode: 'en',
          formattedAddress: data['address'] as String? ?? '',
          googleMapsUri: '',
          location: const Location(lat: 0, lng: 0),
          photos: reference != null && reference.isNotEmpty
              ? [Photo(reference: reference, url: null)]
              : [],
          types: (data['types'] as List?)?.cast<String>() ?? [],
          rating: (data['rating'] as num?)?.toDouble(),
        );
      }).toList();
    });
  }

  // ============================================================================
  // DESTINATIONS MANAGEMENT
  // ============================================================================

  Future<List<Destination>> getRecommendedDestinations() async {
    final snapshot = await _firestore
        .collection('recommendedDestinations')
        .get();
    return snapshot.docs
        .map((doc) => Destination.fromFirestore(doc.data()))
        .toList();
  }

  Stream<List<Destination>> streamRecommendedDestinations() {
    return _firestore
        .collection('recommendedDestinations')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Destination.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // ============================================================================
  // TRIPS MANAGEMENT
  // ============================================================================

  /// Stream trips for a user
  ///
  /// Returns a stream of trips where the user is either the owner or a participant
  Stream<List<Trip>> streamUserTrips(String userId, String? userEmail) {
    // Query trips where the user is either the owner or a participant
    return _trips
        .where(
          Filter.or(
            Filter('userId', isEqualTo: userId),
            Filter('participants', arrayContains: userId),
          ),
        )
        .orderBy('startDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList(),
        );
  }

  Future<String> createTrip({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    required String? userEmail,
    required bool isArchived,
  }) async {
    final tripRef = await _firestore.collection('trips').add({
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isArchived': false,
      'participants': [userId],
    });

    final itineraryRef = tripRef.collection('itineraryDays');
    int dayNumber = 1;
    for (
      DateTime date = startDate;
      !date.isAfter(endDate);
      date = date.add(const Duration(days: 1))
    ) {
      await itineraryRef.add({
        'dayNumber': dayNumber++,
      });
    }

    return tripRef.id;
  }

  Future<void> addPlaceToDay({
    required String tripId,
    required String dayId,
    required Place place,
    int? position,
  }) async {
    // Check if placeId is empty to avoid Firestore error
    if (place.placeId.isEmpty) {
      print('Warning: Attempted to add a place with empty placeId');
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final placesRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('itineraryDays')
        .doc(dayId)
        .collection('places');

    await _firestore.runTransaction((transaction) async {
      // Read current places within the transaction
      final snapshot = await placesRef.orderBy('orderInDay').get();
      final docs = snapshot.docs;

      final placeRef = placesRef.doc(place.placeId);

      // Inserir no final se posição não for informada
      final insertIndex = position ?? docs.length;

      // Set the new place with the correct order
      final newData = {...place.toMap(), 'orderInDay': insertIndex};
      transaction.set(placeRef, newData);

      // Update the order of existing places that need to be shifted
      for (int i = 0; i < docs.length; i++) {
        final doc = docs[i];
        final currentOrder = doc.data()['orderInDay'] as int? ?? i;

        // Only update documents that need to be shifted
        if (currentOrder >= insertIndex) {
          transaction.update(doc.reference, {'orderInDay': currentOrder + 1});
        }
      }

      // Remove dos salvos, se estiver logado
      if (userId != null) {
        final savedRef = _savedPlacesCollection(userId).doc(place.placeId);
        transaction.delete(savedRef);
      }
    });
  }

  Future<void> reorderPlacesWithinDay({
    required String tripId,
    required String dayId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final placesRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('itineraryDays')
        .doc(dayId)
        .collection('places');

    await _firestore.runTransaction((transaction) async {
      // Read current places within the transaction
      final snapshot = await placesRef.orderBy('orderInDay').get();
      final docs = snapshot.docs;

      if (oldIndex < 0 ||
          oldIndex >= docs.length ||
          newIndex < 0 ||
          newIndex >= docs.length) {
        return;
      }

      final movedDoc = docs.removeAt(oldIndex);
      docs.insert(newIndex, movedDoc);

      // Update all documents with new order
      for (int i = 0; i < docs.length; i++) {
        transaction.update(docs[i].reference, {'orderInDay': i});
      }
    });
  }

  Future<void> removePlaceFromDay({
    required String tripId,
    required String dayId,
    required Place place,
  }) async {
    // Check if placeId is empty to avoid Firestore error
    if (place.placeId.isEmpty) {
      print('Warning: Attempted to remove a place with empty placeId');
      return;
    }

    final placesRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('itineraryDays')
        .doc(dayId)
        .collection('places');

    await _firestore.runTransaction((transaction) async {
      final placeRef = placesRef.doc(place.placeId);

      // Check if place exists within the transaction
      final doc = await transaction.get(placeRef);
      if (!doc.exists) return;

      // Get all places before making changes
      final snapshot = await placesRef.orderBy('orderInDay').get();

      // Delete the place
      transaction.delete(placeRef);

      // Reorder remaining places
      int newOrder = 0;
      for (final doc in snapshot.docs) {
        if (doc.id != place.placeId) {
          transaction.update(doc.reference, {'orderInDay': newOrder++});
        }
      }
    });
  }

  // Stream itinerary days for a trip
  Stream<List<ItineraryDay>> streamItineraryDays(String tripId) {
    return _trips
        .doc(tripId)
        .collection('itineraryDays')
        .orderBy('dayNumber')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ItineraryDay.fromFirestore(doc))
              .toList(),
        );
  }

  // Stream places for a specific day
  Stream<List<Place>> streamPlacesForDay({
    required String tripId,
    required String dayId,
  }) {
    return _trips
        .doc(tripId)
        .collection('itineraryDays')
        .doc(dayId)
        .collection('places')
        .orderBy('orderInDay')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Place.fromJson(doc.data())).toList(),
        );
  }

  // ============================================================================
  // GROUPS FEEDBACK MANAGEMENT
  // ============================================================================

  Stream<Map<String, dynamic>?> streamGroupsFeedbackSummary() {
    return _groupsFeedback
        .doc('summary')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  Stream<Map<String, dynamic>?> streamUserFeedback(String userId) {
    return _groupsFeedback
        .doc('users')
        .collection('responses')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  Future<void> submitGroupsFeedback({
    required String userId,
    required bool wantsGroupFeature,
  }) async {
    await _firestore.runTransaction((transaction) async {
      // References
      final summaryRef = _groupsFeedback.doc('summary');
      final userRef = _groupsFeedback
          .doc('users')
          .collection('responses')
          .doc(userId);

      // Get current summary
      final summaryDoc = await transaction.get(summaryRef);
      final summaryData = summaryDoc.exists
          ? summaryDoc.data()!
          : <String, dynamic>{};

      // Get current user response (to check if updating)
      final userDoc = await transaction.get(userRef);
      final hadPreviousResponse = userDoc.exists;
      final previousResponse = hadPreviousResponse
          ? userDoc.data()!['wantsGroupFeature'] as bool?
          : null;

      // Update user response
      transaction.set(userRef, {
        'wantsGroupFeature': wantsGroupFeature,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      // Update summary counts
      int yesCount = summaryData['yesCount'] ?? 0;
      int noCount = summaryData['noCount'] ?? 0;
      int totalResponses = summaryData['totalResponses'] ?? 0;

      if (hadPreviousResponse && previousResponse != null) {
        // User is changing their response
        if (previousResponse) {
          yesCount--;
        } else {
          noCount--;
        }
      } else {
        // New response
        totalResponses++;
      }

      if (wantsGroupFeature) {
        yesCount++;
      } else {
        noCount++;
      }

      transaction.set(summaryRef, {
        'yesCount': yesCount,
        'noCount': noCount,
        'totalResponses': totalResponses,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  // ============================================================================
  // USER PROFILE MANAGEMENT
  // ============================================================================

  /// Initialize user profile with default badges and challenges
  Future<void> initializeUserProfile(String userId) async {
    final batch = _firestore.batch();

    // Initialize badges
    for (final badge in badge_model.PredefinedBadges.allBadges) {
      final badgeRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc(badge.id);
      batch.set(badgeRef, badge.toFirestore());
    }

    // Initialize travel cover collection
    final coverCollectionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('travelCovers')
        .doc('collection');

    final emptyCollection = TravelCoverCollection(
      userId: userId,
      covers: [],
      totalUnlocked: 0,
    );
    batch.set(coverCollectionRef, emptyCollection.toFirestore());

    // Initialize challenge progress for current challenges
    final activeChallenges = PredefinedChallenges.getActiveChallenges();

    for (final challenge in activeChallenges) {
      final progressRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('challengeProgress')
          .doc(challenge.id);
      batch.set(progressRef, {'progress': 0});
    }

    await batch.commit();
    debugPrint('FirestoreService: Initialized profile for user $userId');
  }

  // ============================================================================
  // BADGES MANAGEMENT
  // ============================================================================

  /// Get user badges
  Stream<List<badge_model.Badge>> getUserBadges(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('badges')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => badge_model.Badge.fromFirestore(doc.data()))
              .toList(),
        );
  }

  /// Unlock a badge for the user
  Future<void> unlockBadge(String userId, String badgeId) async {
    final badgeRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('badges')
        .doc(badgeId);

    await badgeRef.update({
      'isUnlocked': true,
      'unlockedAt': DateTime.now().millisecondsSinceEpoch,
    });

    debugPrint('FirestoreService: Unlocked badge $badgeId for user $userId');
  }

  // ============================================================================
  // TRAVEL COVERS MANAGEMENT
  // ============================================================================

  /// Get user travel cover collection
  Stream<TravelCoverCollection?> getUserTravelCovers(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('travelCovers')
        .doc('collection')
        .snapshots()
        .map(
          (doc) => doc.exists
              ? TravelCoverCollection.fromFirestore(doc.data()!)
              : null,
        );
  }

  /// Add a travel cover to user's collection
  Future<void> addTravelCover(String userId, TravelCover cover) async {
    final coverCollectionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('travelCovers')
        .doc('collection');

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(coverCollectionRef);

      if (doc.exists) {
        final collection = TravelCoverCollection.fromFirestore(doc.data()!);
        final updatedCovers = [...collection.covers, cover];
        final updatedCollection = collection.copyWith(
          covers: updatedCovers,
          totalUnlocked: cover.isUnlocked
              ? collection.totalUnlocked + 1
              : collection.totalUnlocked,
        );
        transaction.update(coverCollectionRef, updatedCollection.toFirestore());
      } else {
        final newCollection = TravelCoverCollection(
          userId: userId,
          covers: [cover],
          totalUnlocked: cover.isUnlocked ? 1 : 0,
        );
        transaction.set(coverCollectionRef, newCollection.toFirestore());
      }
    });

    debugPrint(
      'FirestoreService: Added travel cover ${cover.id} for user $userId',
    );
  }

  // ============================================================================
  // CHALLENGES MANAGEMENT
  // ============================================================================

  /// Get active challenges for user
  Stream<List<Challenge>> getActiveChallenges(String userId) {
    final now = DateTime.now();
    return _firestore
        .collection('challenges')
        .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: now.millisecondsSinceEpoch)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Challenge.fromFirestore(doc.data()))
              .toList(),
        );
  }

  /// Get user's challenge progress
  Stream<Map<String, int>> getUserChallengeProgress(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('challengeProgress')
        .snapshots()
        .map((snapshot) {
          final Map<String, int> progress = {};
          for (final doc in snapshot.docs) {
            progress[doc.id] = doc.data()['progress'] as int? ?? 0;
          }
          return progress;
        });
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress(
    String userId,
    String challengeId,
    int progress,
  ) async {
    final progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('challengeProgress')
        .doc(challengeId);

    await progressRef.set({'progress': progress}, SetOptions(merge: true));
    debugPrint(
      'FirestoreService: Updated challenge $challengeId progress to $progress for user $userId',
    );
  }

  /// Get challenge progress for a specific challenge
  Future<int> getChallengeProgress(String userId, String challengeId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('challengeProgress')
        .doc(challengeId)
        .get();

    return doc.exists ? (doc.data()?['progress'] as int? ?? 0) : 0;
  }

  // ============================================================================
  // TRAVELER PROFILE MANAGEMENT
  // ============================================================================

  /// Get user's traveler profile
  Future<TravelerProfile?> getTravelerProfile(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('traveler_profile')
        .get();

    if (!doc.exists) return null;

    try {
      return TravelerProfile.fromJson(doc.data()!);
    } catch (e) {
      debugPrint(
        'FirestoreService: Error parsing traveler profile for user $userId: $e',
      );
      return null;
    }
  }

  /// Stream user's traveler profile
  Stream<TravelerProfile?> streamTravelerProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('traveler_profile')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;

          try {
            return TravelerProfile.fromJson(doc.data()!);
          } catch (e) {
            debugPrint(
              'FirestoreService: Error parsing traveler profile for user $userId: $e',
            );
            return null;
          }
        });
  }

  /// Save user's traveler profile
  Future<void> saveTravelerProfile(
    String userId,
    TravelerProfile profile,
  ) async {
    final profileRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('traveler_profile');

    await profileRef.set(profile.toJson(), SetOptions(merge: true));
    debugPrint('FirestoreService: Saved traveler profile for user $userId');
  }

  /// Delete user's traveler profile
  Future<void> deleteTravelerProfile(String userId) async {
    final profileRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('traveler_profile');

    await profileRef.delete();
    debugPrint('FirestoreService: Deleted traveler profile for user $userId');
  }

  /// Check if user has a traveler profile
  Future<bool> hasTravelerProfile(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('traveler_profile')
        .get();

    return doc.exists;
  }

  // ============================================================================
  // USER ACCOUNT DELETION
  // ============================================================================

  /// Delete all user data from Firestore
  /// This should be called before deleting the Firebase Auth account
  Future<void> deleteAllUserData(String userId) async {
    final batch = _firestore.batch();

    try {
      // Delete user's main document
      final userDoc = _users.doc(userId);
      batch.delete(userDoc);

      // Delete all saved places
      final savedPlacesQuery = await _savedPlacesCollection(userId).get();
      for (final doc in savedPlacesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete traveler profile
      final profileRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('traveler_profile');
      batch.delete(profileRef);

      // Delete challenge progress
      final challengeProgressQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challengeProgress')
          .get();
      for (final doc in challengeProgressQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user badges
      final badgesQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .get();
      for (final doc in badgesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user travel covers
      final coversQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('travelCovers')
          .get();
      for (final doc in coversQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete trips where user is the owner
      final tripsQuery = await _trips.where('ownerId', isEqualTo: userId).get();
      for (final doc in tripsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete groups feedback submitted by user
      final feedbackQuery = await _groupsFeedback
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in feedbackQuery.docs) {
        batch.delete(doc.reference);
      }

      // Commit all deletions
      await batch.commit();
      debugPrint(
        'FirestoreService: Successfully deleted all data for user $userId',
      );
    } catch (e) {
      debugPrint('FirestoreService: Error deleting user data for $userId: $e');
      rethrow;
    }
  }
}
