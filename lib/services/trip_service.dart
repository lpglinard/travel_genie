import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_genie/services/day_summary_service.dart';

import '../models/itinerary_day.dart';
import '../models/place.dart';
import '../models/trip.dart';
import 'firestore_service.dart';

class TripService {
  final FirestoreService _firestoreService;
  final DaySummaryService _daySummaryService;

  TripService(this._firestoreService, this._daySummaryService);

  /// Stream trips for the current user
  Stream<List<Trip>> getUserTrips() {
    final user = FirebaseAuth.instance.currentUser;

    // If no user is logged in, return an empty list
    if (user == null) {
      return Stream.value([]);
    }

    // Use FirestoreService to stream user trips
    return _firestoreService.streamUserTrips(user.uid, user.email);
  }

  /// Create a new trip
  Future<String> createTrip({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String coverImageUrl = '',
    bool isArchived = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    return _firestoreService.createTrip(
      userId: user.uid,
      userEmail: user.email,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      coverImageUrl: coverImageUrl,
      isArchived: isArchived,
    );
  }

  // Add other trip-related methods here
  // Delegando acesso aos dados reativos do Firestore

  Stream<List<ItineraryDay>> streamItineraryDays(String tripId) {
    return _firestoreService.streamItineraryDays(tripId);
  }

  Stream<List<Place>> streamPlacesForDay({
    required String tripId,
    required String dayId,
  }) {
    return _firestoreService.streamPlacesForDay(tripId: tripId, dayId: dayId);
  }

  Stream<List<Place>> streamSavedPlacesForCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _firestoreService.streamSavedPlacesAsPlaces(user.uid);
  }

  Future<void> addPlaceToDay({
    required String tripId,
    required String dayId,
    required Place place,
    required int position,
  }) {
    return _firestoreService.addPlaceToDay(
      tripId: tripId,
      dayId: dayId,
      place: place,
      position: position,
    ).then((onValue) {
      _daySummaryService.getDaySummary(
        tripId: tripId,
        dayId: dayId,
        languageCode: 'en',
      ).then((value) {
        // Optionally, you can handle any post-removal logic here
        debugPrint('Day summary fetched after adding place: $value');
      }).catchError((error) {
        debugPrint('Error fetching day summary after adding place: $error');
      });
    });
  }

  Future<void> reorderPlacesWithinDay({
    required String tripId, 
    required String dayId, 
    required int oldIndex, 
    required int newIndex, 
  }) async {
    return _firestoreService.reorderPlacesWithinDay(
      tripId: tripId,
      dayId: dayId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    ).then((value) {
      // Optionally, you can handle any post-reorder logic here
      _daySummaryService.getDaySummary(
        tripId: tripId,
        dayId: dayId,
        languageCode: 'en',
      ).then((value) {
        // Optionally, you can handle any post-removal logic here
        debugPrint('Day summary fetched after reordering place: $value');
      }).catchError((error) {
        debugPrint('Error fetching day summary after reordering place: $error');
      });
    });
  }

  Future<void> removePlaceFromDay({required String tripId, required String dayId, required Place place}) async {
    return _firestoreService.removePlaceFromDay(
      tripId: tripId,
      dayId: dayId,
      place: place,
    ).then((onValue) {
      _daySummaryService.getDaySummary(
        tripId: tripId,
        dayId: dayId,
        languageCode: 'en',
      ).then((value) {
        // Optionally, you can handle any post-removal logic here
        debugPrint('Day summary fetched after removing place: $value');
      }).catchError((error) {
        debugPrint('Error fetching day summary after removing place: $error');
      });
    });
  }
}
