import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../models/itinerary_day.dart';
import '../models/location.dart';
import '../models/photo.dart';
import '../models/place.dart';
import '../models/trip.dart';
import '../models/user_data.dart';

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<UserData> streamUser(String uid) {
    return _users.doc(uid).snapshots().map(UserData.fromDoc);
  }

  Future<void> upsertUser(User user, {Locale? locale, bool? darkMode}) {
    final doc = _users.doc(user.uid);
    final data = <String, dynamic>{
      'name': user.displayName,
      'email': user.email,
    };
    if (locale != null) {
      data['locale'] = locale.languageCode;
    }
    if (darkMode != null) {
      data['darkMode'] = darkMode;
    }
    return doc.set(data, SetOptions(merge: true));
  }

  CollectionReference<Map<String, dynamic>> _savedPlacesCollection(String userId) {
    return _users.doc(userId).collection('saved_places');
  }

  Future<void> savePlace(String userId, Place place) async {
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
    await _savedPlacesCollection(userId).doc(placeId).delete();
  }

  Future<bool> isPlaceSaved(String userId, String placeId) async {
    final docSnapshot = await _savedPlacesCollection(userId).doc(placeId).get();
    return docSnapshot.exists;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSavedPlaces(String userId) {
    return _savedPlacesCollection(userId)
        .orderBy('savedDate', descending: true)
        .snapshots();
  }

  Future<List<Destination>> getRecommendedDestinations() async {
    final snapshot = await _firestore.collection('recommendedDestinations').get();
    return snapshot.docs.map((doc) => Destination.fromFirestore(doc.data())).toList();
  }

  Stream<List<Destination>> streamRecommendedDestinations() {
    return _firestore.collection('recommendedDestinations').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Destination.fromFirestore(doc.data()))
          .toList(),
    );
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

  // Stream dias da viagem (itinerary_days)
  Stream<List<ItineraryDay>> streamItineraryDays(String tripId) {
    return _trips
        .doc(tripId)
        .collection('itinerary_days')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ItineraryDay.fromFirestore(doc))
        .toList());
  }

  // Stream lugares de um dia
  Stream<List<Place>> streamPlacesForDay({
    required String tripId,
    required String dayId,
  }) {
    return _trips
        .doc(tripId)
        .collection('itinerary_days')
        .doc(dayId)
        .collection('places')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Place.fromJson(doc.data()))
        .toList());
  }

  CollectionReference<Map<String, dynamic>> get _trips =>
      _firestore.collection('trips');

  /// Stream trips for a user
  /// 
  /// Returns a stream of trips where the user is either the owner or a participant
  Stream<List<Trip>> streamUserTrips(String userId, String? userEmail) {
    // If no user email is provided, just query by userId
    if (userEmail == null) {
      return _trips
          .where('userId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
    }

    // Query trips where the user is either the owner or a participant
    return _trips
        .where(
          Filter.or(
            Filter('userId', isEqualTo: userId),
            Filter('participants', arrayContains: userEmail),
          ),
        )
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }

  Future<String> createTrip({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    required String? userEmail,
    required bool isArchived,
    required String coverImageUrl,
  }) async {
    final tripRef = await _firestore.collection('trips').add({
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'coverImageUrl': '',
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isArchived': false,
      'participants': userEmail != null ? [userEmail] : [],
    });

    final itineraryRef = tripRef.collection('itinerary_days');
    int order = 0;
    for (DateTime date = startDate;
    !date.isAfter(endDate);
    date = date.add(const Duration(days: 1))) {
      await itineraryRef.add({
        'date': Timestamp.fromDate(date),
        'order': order++,
      });
    }

    return tripRef.id;
  }

  Future<void> addPlaceToDay({
    required String tripId,
    required String dayId,
    required Place place,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final batch = _firestore.batch();

    final placesRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('itinerary_days')
        .doc(dayId)
        .collection('places');

    final snapshot = await placesRef.orderBy('order', descending: true).limit(1).get();
    final lastOrder = snapshot.docs.isNotEmpty
        ? (snapshot.docs.first.data()['order'] as int? ?? -1)
        : -1;

    final newOrder = lastOrder + 1;

    final placeRef = placesRef.doc(place.placeId);
    batch.set(placeRef, {
      ...place.toMap(),
      'order': newOrder,
    });

    final savedRef = _savedPlacesCollection(userId).doc(place.placeId);
    batch.delete(savedRef);

    await batch.commit();
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
        .collection('itinerary_days')
        .doc(dayId)
        .collection('places');

    final snapshot = await placesRef.orderBy('order').get();
    final docs = snapshot.docs;

    if (oldIndex < 0 || oldIndex >= docs.length || newIndex < 0 || newIndex >= docs.length) {
      return;
    }

    final movedDoc = docs.removeAt(oldIndex);
    docs.insert(newIndex, movedDoc);

    final batch = _firestore.batch();
    for (int i = 0; i < docs.length; i++) {
      batch.update(docs[i].reference, {'order': i});
    }

    await batch.commit();
  }

}
