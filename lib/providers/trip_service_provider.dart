import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';
import '../user_providers.dart';
import 'day_summary_service_provider.dart';

/// Provider for TripService
///
/// This provider exposes the TripService which includes:
/// - createTrip method for creating new trips
/// - Other trip-related functionality
final tripServiceProvider = Provider<TripService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final daySummaryService = ref.watch(daySummaryServiceProvider);
  final locale = ref.watch(localeProvider);
  return TripService(firestoreService, daySummaryService, locale?.languageCode);
});

/// Provider that exposes a stream of user trips
final userTripsProvider = StreamProvider<List<Trip>>((ref) {
  final tripService = ref.watch(tripServiceProvider);

  // Watch auth state changes to ensure data is cleared when user logs out
  return ref.watch(authStateChangesProvider).when(
    data: (user) {
      if (user == null) {
        return Stream.value(<Trip>[]);
      }
      return tripService.getUserTrips();
    },
    loading: () => Stream.value(<Trip>[]),
    error: (_, __) => Stream.value(<Trip>[]),
  );
});

final savedPlacesProvider = StreamProvider<List<Place>>((ref) {
  final tripService = ref.watch(tripServiceProvider);

  // Watch auth state changes to ensure data is cleared when user logs out
  return ref.watch(authStateChangesProvider).when(
    data: (user) {
      if (user == null) {
        return Stream.value(<Place>[]);
      }
      return tripService.streamSavedPlacesForCurrentUser();
    },
    loading: () => Stream.value(<Place>[]),
    error: (_, __) => Stream.value(<Place>[]),
  );
});
