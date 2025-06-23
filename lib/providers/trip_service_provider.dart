import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';
import '../user_providers.dart';

/// Provider for TripService
/// 
/// This provider exposes the TripService which includes:
/// - createTrip method for creating new trips
/// - Other trip-related functionality
final tripServiceProvider = Provider<TripService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return TripService(firestoreService);
});

/// Provider that exposes a stream of user trips
final userTripsProvider = StreamProvider<List<Trip>>((ref) {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.getUserTrips();
});
final savedPlacesProvider = StreamProvider<List<Place>>((ref) {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.streamSavedPlacesForCurrentUser();
});