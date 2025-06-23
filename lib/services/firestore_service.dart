import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/destination.dart';
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

  // Get reference to a user's saved places collection
  CollectionReference<Map<String, dynamic>> _savedPlacesCollection(
    String userId,
  ) {
    return _users.doc(userId).collection('saved_places');
  }

  // Save a place to user's saved places
  Future<void> savePlace(String userId, Place place) async {
    final savedPlacesRef = _savedPlacesCollection(userId);

    // Get the first photo URL if available
    String? reference;
    if (place.photos.isNotEmpty && place.photos.first.reference != null) {
      reference = place.photos.first.reference;
    }

    // Create the document with the place data
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

  // Remove a place from user's saved places
  Future<void> removePlace(String userId, String placeId) async {
    await _savedPlacesCollection(userId).doc(placeId).delete();
  }

  // Check if a place is saved by the user
  Future<bool> isPlaceSaved(String userId, String placeId) async {
    final docSnapshot = await _savedPlacesCollection(userId).doc(placeId).get();
    return docSnapshot.exists;
  }

  // Get all saved places for a user
  Stream<QuerySnapshot<Map<String, dynamic>>> streamSavedPlaces(String userId) {
    return _savedPlacesCollection(
      userId,
    ).orderBy('savedDate', descending: true).snapshots();
  }

  // Get recommended destinations from Firestore
  Future<List<Destination>> getRecommendedDestinations() async {
    final snapshot = await _firestore
        .collection('recommendedDestinations')
        .get();
    return snapshot.docs
        .map((doc) => Destination.fromFirestore(doc.data()))
        .toList();
  }

  // Stream recommended destinations from Firestore
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

  // Get reference to the trips collection
  CollectionReference<Map<String, dynamic>> get _trips =>
      _firestore.collection('trips');

  Stream<List<Trip>> streamUserTrips(String userId, {required String userEmail}) {
    final tripsCollection = FirebaseFirestore.instance.collection('trips');

    final query = tripsCollection.where(
      Filter.or(
        Filter('userId', isEqualTo: userId),
        Filter('participants', arrayContains: userEmail),
      ),
    );

    return query
        .orderBy('startDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final trips = <Trip>[];

          for (final doc in snapshot.docs) {
            // Get the trip without places first
            final trip = Trip.fromFirestore(doc);

            // Get places from the sub-collection
            final placesSnapshot = await _tripPlacesCollection(trip.id).get();
            final places = placesSnapshot.docs.map((placeDoc) {
              final data = placeDoc.data();
              return Place.fromJson(data);
            }).toList();

            // Add the trip with places to the list
            trips.add(trip.copyWith(places: places));
          }

          return trips;
        });
  }

  // Get a specific trip by ID with places from sub-collection
  Future<Trip?> getTrip(String tripId) async {
    final doc = await _trips.doc(tripId).get();
    if (!doc.exists) {
      return null;
    }

    // Get the trip without places first
    final trip = Trip.fromFirestore(doc);

    // Get places from the sub-collection
    final placesSnapshot = await _tripPlacesCollection(tripId).get();
    final places = placesSnapshot.docs.map((placeDoc) {
      final data = placeDoc.data();
      return Place.fromJson(data);
    }).toList();

    // Return a new Trip with the places from the sub-collection
    return trip.copyWith(places: places);
  }

  // Get reference to a trip's places sub-collection
  CollectionReference<Map<String, dynamic>> _tripPlacesCollection(String tripId) {
    return _trips.doc(tripId).collection('places');
  }

  // Add a place to a trip using a sub-collection
  Future<void> addPlaceToTrip(String tripId, Place place) async {
    final tripDoc = await _trips.doc(tripId).get();
    if (!tripDoc.exists) {
      throw Exception('Trip not found');
    }

    // Get reference to the places sub-collection
    final placesCollection = _tripPlacesCollection(tripId);

    // Check if the place already exists in the sub-collection
    final existingPlaceDoc = await placesCollection.doc(place.placeId).get();
    if (existingPlaceDoc.exists) {
      // Place already exists in the trip
      return;
    }

    // Add the place to the places sub-collection
    await placesCollection.doc(place.placeId).set({
      'placeId': place.placeId,
      'displayName': place.displayName,
      'formattedAddress': place.formattedAddress,
      'googleMapsUri': place.googleMapsUri,
      'websiteUri': place.websiteUri,
      'types': place.types,
      'rating': place.rating,
      'userRatingCount': place.userRatingCount,
      'location': {
        'lat': place.location.lat,
        'lng': place.location.lng,
      },
      'photos': place.photos.map((photo) => {
        'reference': photo.reference,
        if (photo.url != null) 'url': photo.url,
      }).toList(),
      'addedAt': FieldValue.serverTimestamp(),
    });

    // Update the trip document's updatedAt field
    await _trips.doc(tripId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get saved places for a user as Place objects
  Stream<List<Place>> streamSavedPlacesAsPlaces(String userId) {
    return streamSavedPlaces(userId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Create a minimal Place object from the saved place data
        return Place(
          placeId: data['placeId'] as String? ?? '',
          displayName: data['name'] as String? ?? '',
          displayNameLanguageCode: 'en', // Default to English
          formattedAddress: data['address'] as String? ?? '',
          googleMapsUri: '', // Not stored in saved places
          location: const Location(lat: 0, lng: 0), // Default location
          photos: data['reference'] != null
              ? [Photo(reference: data['reference'] as String, url: null)]
              : [],
          types: (data['types'] as List?)?.cast<String>() ?? [],
          rating: (data['rating'] as num?)?.toDouble(),
        );
      }).toList();
    });
  }
}
