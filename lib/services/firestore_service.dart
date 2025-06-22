import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../models/place.dart';
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
    String? imageUrl;
    if (place.photos.isNotEmpty) {
      imageUrl = place.photos.first.url;
    }

    // Create the document with the place data
    await savedPlacesRef.doc(place.placeId).set({
      'placeId': place.placeId,
      'name': place.displayName,
      'image': imageUrl,
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
}
