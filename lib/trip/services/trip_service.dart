import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:travel_genie/models/itinerary_day.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/models/trip.dart';
import 'package:travel_genie/services/analytics_service.dart';

import '../models/trip_participant.dart';

/// Abstract interface for trip data operations
abstract class TripRepository {
  Future<String> createTrip(Trip trip);

  Future<Trip?> getTripById(String tripId);

  /// Stream trip data for real-time updates
  Stream<Trip?> streamTripById(String tripId);

  Future<List<TripParticipant>> getTripParticipants(String tripId);

  Future<List<Place>> getTripPlaces(String tripId);

  Future<List<ItineraryDay>> getTripItinerary(String tripId);

  Future<List<Place>> getItineraryDayPlaces(String tripId, String dayId);

  Future<void> updateItineraryDay(String tripId, ItineraryDay day);

  Stream<List<ItineraryDay>> streamItineraryDays(String tripId);

  Stream<List<Place>> streamPlacesForDay({
    required String tripId,
    required String dayId,
  });

  Future<void> addParticipant(String tripId, TripParticipant participant);

  Future<void> removeParticipant(String tripId, String userId);
}

/// Concrete implementation of TripRepository using Firestore
class FirestoreTripRepository implements TripRepository {
  FirestoreTripRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<String> createTrip(Trip trip) async {
    try {
      final docRef = await _firestore
          .collection('trips')
          .add(trip.toFirestore());
      return docRef.id;
    } catch (e) {
      throw TripServiceException('Failed to create trip: $e');
    }
  }

  @override
  Future<Trip?> getTripById(String tripId) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (!doc.exists) return null;
      return Trip.fromFirestore(doc);
    } catch (e) {
      throw TripServiceException('Failed to fetch trip: $e');
    }
  }

  @override
  Stream<Trip?> streamTripById(String tripId) {
    try {
      return _firestore
          .collection('trips')
          .doc(tripId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return Trip.fromFirestore(doc);
      });
    } catch (e) {
      throw TripServiceException('Failed to stream trip: $e');
    }
  }

  @override
  Future<List<TripParticipant>> getTripParticipants(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('participants')
          .get();

      return snapshot.docs
          .map((doc) => TripParticipant.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw TripServiceException('Failed to fetch participants: $e');
    }
  }

  @override
  Future<List<Place>> getTripPlaces(String tripId) async {
    try {
      // Since ItineraryDay now only has dayNumber, return empty list
      // Places functionality is simplified
      return [];
    } catch (e) {
      throw TripServiceException('Failed to fetch places: $e');
    }
  }

  @override
  Future<List<ItineraryDay>> getTripItinerary(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('itineraryDays')
          .orderBy('dayNumber')
          .get();

      return snapshot.docs
          .map((doc) => ItineraryDay.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw TripServiceException('Failed to fetch itinerary: $e');
    }
  }

  @override
  Future<List<Place>> getItineraryDayPlaces(String tripId, String dayId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('itineraryDays')
          .doc(dayId)
          .collection('places')
          .orderBy('orderInDay')
          .get();

      return snapshot.docs.map((doc) => Place.fromJson(doc.data())).toList();
    } catch (e) {
      throw TripServiceException('Failed to fetch itinerary day places: $e');
    }
  }

  @override
  Future<void> updateItineraryDay(String tripId, ItineraryDay day) async {
    try {
      await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('itineraryDays')
          .doc(day.id)
          .update(day.toFirestore());
    } catch (e) {
      throw TripServiceException('Failed to update itinerary day: $e');
    }
  }

  @override
  Stream<List<ItineraryDay>> streamItineraryDays(String tripId) {
    try {
      return _firestore
          .collection('trips')
          .doc(tripId)
          .collection('itineraryDays')
          .orderBy('dayNumber')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ItineraryDay.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw TripServiceException('Failed to stream itinerary days: $e');
    }
  }

  @override
  Stream<List<Place>> streamPlacesForDay({
    required String tripId,
    required String dayId,
  }) {
    try {
      return _firestore
          .collection('trips')
          .doc(tripId)
          .collection('itineraryDays')
          .doc(dayId)
          .collection('places')
          .orderBy('orderInDay')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Place.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw TripServiceException('Failed to stream places for day: $e');
    }
  }

  @override
  Future<void> addParticipant(
    String tripId,
    TripParticipant participant,
  ) async {
    try {
      await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('participants')
          .doc(participant.userId)
          .set(participant.toFirestore());
    } catch (e) {
      throw TripServiceException('Failed to add participant: $e');
    }
  }

  @override
  Future<void> removeParticipant(String tripId, String userId) async {
    try {
      await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('participants')
          .doc(userId)
          .delete();
    } catch (e) {
      throw TripServiceException('Failed to remove participant: $e');
    }
  }
}

/// Service for trip-related business logic
class TripService {
  TripService(this._repository, this._analyticsService);

  final TripRepository _repository;
  final AnalyticsService _analyticsService;

  Future<String> createTrip(Trip trip) async {
    final tripId = await _repository.createTrip(trip);

    // Log trip creation as conversion goal using Firebase standard begin_checkout event
    await _analyticsService.logCreateItinerary(
      tripId: tripId,
      destination: trip.title,
      value: 0.0,
      currency: 'USD',
      items: [
        AnalyticsEventItem(
          itemId: tripId,
          itemName: trip.title,
          itemCategory: 'trip',
          parameters: {
            'destination': trip.title,
            'start_date': trip.startDate.toIso8601String(),
            'end_date': trip.endDate.toIso8601String(),
            'duration_days': trip.endDate.difference(trip.startDate).inDays + 1,
          },
        ),
      ],
    );

    return tripId;
  }

  Future<Trip?> getTripDetails(String tripId) async {
    final trip = await _repository.getTripById(tripId);

    // Log trip viewing using Firebase standard view_item event
    if (trip != null) {
      await _analyticsService.logViewItinerary(
        tripId: tripId,
        destination: trip.title,
        value: 0.0,
        currency: 'USD',
        items: [
          AnalyticsEventItem(
            itemId: tripId,
            itemName: trip.title,
            itemCategory: 'trip',
            parameters: {
              'destination': trip.title,
              'start_date': trip.startDate.toIso8601String(),
              'end_date': trip.endDate.toIso8601String(),
              'duration_days': trip.endDate.difference(trip.startDate).inDays + 1,
            },
          ),
        ],
      );
    }

    return trip;
  }

  /// Stream trip details for real-time updates
  Stream<Trip?> streamTripDetails(String tripId) {
    return _repository.streamTripById(tripId);
  }

  Future<List<TripParticipant>> getParticipants(String tripId) async {
    final participants = await _repository.getTripParticipants(tripId);
    // Create a mutable copy and sort organizers first
    final sortedParticipants = List<TripParticipant>.from(participants);
    sortedParticipants.sort((a, b) {
      if (a.isOrganizer && !b.isOrganizer) return -1;
      if (!a.isOrganizer && b.isOrganizer) return 1;
      return a.displayName.compareTo(b.displayName);
    });
    return sortedParticipants;
  }

  Future<Trip> getTripWithDetails(String tripId) async {
    final trip = await _repository.getTripById(tripId);
    if (trip == null) {
      throw TripServiceException('Trip not found');
    }

    final places = await _repository.getTripPlaces(tripId);
    final itinerary = await _repository.getTripItinerary(tripId);

    // Since ItineraryDay is simplified, just return the basic itinerary
    return trip.copyWith(places: places, itinerary: itinerary);
  }

  Future<void> addParticipant(
    String tripId,
    TripParticipant participant,
  ) async {
    await _repository.addParticipant(tripId, participant);
  }

  Future<void> removeParticipant(String tripId, String userId) async {
    await _repository.removeParticipant(tripId, userId);
  }

  Future<void> updateItineraryDay(String tripId, ItineraryDay day) async {
    await _repository.updateItineraryDay(tripId, day);
  }

  Stream<List<ItineraryDay>> streamItineraryDays(String tripId) {
    return _repository.streamItineraryDays(tripId);
  }

  Stream<List<Place>> streamPlacesForDay({
    required String tripId,
    required String dayId,
  }) {
    return _repository.streamPlacesForDay(tripId: tripId, dayId: dayId);
  }

  String formatDateRange(DateTime startDate, DateTime endDate) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final startMonth = months[startDate.month - 1];
    final endMonth = months[endDate.month - 1];

    if (startDate.month == endDate.month) {
      return '$startMonth ${startDate.day} - ${endDate.day}';
    } else {
      return '$startMonth ${startDate.day} - $endMonth ${endDate.day}';
    }
  }
}

/// Custom exception for trip service operations
class TripServiceException implements Exception {
  const TripServiceException(this.message);

  final String message;

  @override
  String toString() => 'TripServiceException: $message';
}
