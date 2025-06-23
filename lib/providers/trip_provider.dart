import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../models/trip.dart';
import '../services/firestore_service.dart';
import 'user_providers.dart';

/// Represents the state of trips
class TripsState {
  /// The list of trips
  final List<Trip> trips;

  /// Any error that occurred during fetching
  final Object? error;

  /// Whether the trips are in a loading state
  final bool isLoading;

  const TripsState({
    this.trips = const [],
    this.error,
    this.isLoading = false,
  });

  /// Creates an empty state with no trips
  factory TripsState.empty() => const TripsState();

  /// Creates a loading state
  factory TripsState.loading() => const TripsState(isLoading: true);

  /// Creates a state with the given error
  factory TripsState.error(Object error) => TripsState(error: error);

  /// Creates a copy of this state with the given fields replaced
  TripsState copyWith({
    List<Trip>? trips,
    Object? error,
    bool? isLoading,
  }) {
    return TripsState(
      trips: trips ?? this.trips,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier that manages trips state
class TripsNotifier extends StateNotifier<TripsState> {
  TripsNotifier(this._service, this._auth) : super(TripsState.empty()) {
    // Load trips when the notifier is created if user is logged in
    if (_auth.currentUser != null) {
      loadTrips();
    }
  }

  final FirestoreService _service;
  final FirebaseAuth _auth;

  /// Loads trips for the current user
  Future<void> loadTrips() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = TripsState.empty();
      return;
    }

    state = TripsState.loading();

    try {
      // Start listening to the stream of trips
      _service.streamUserTrips(user.uid,userEmail: user.email ?? "").listen(
        (trips) {
          state = TripsState(trips: trips);
        },
        onError: (error) {
          state = TripsState.error(error);
        },
      );
    } catch (e) {
      state = TripsState.error(e);
    }
  }

  /// Gets a specific trip by ID
  Future<Trip?> getTrip(String tripId) async {
    try {
      return await _service.getTrip(tripId);
    } catch (e) {
      state = state.copyWith(error: e);
      return null;
    }
  }

  /// Adds a place to a trip
  Future<void> addPlaceToTrip(String tripId, Place place) async {
    try {
      await _service.addPlaceToTrip(tripId, place);
      // Refresh the trip after adding the place
      await getTrip(tripId);
    } catch (e) {
      state = state.copyWith(error: e);
    }
  }
}

/// Provider for trips
final tripsProvider = StateNotifierProvider<TripsNotifier, TripsState>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  final auth = FirebaseAuth.instance;
  return TripsNotifier(service, auth);
}, name: 'tripsProvider');
