

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/trip/models/destination.dart';
import '../../features/trip/models/trip.dart';
import '../../features/trip/providers/trip_providers.dart';
import 'infrastructure_providers.dart';

/// Provider for recommended destinations
final recommendedDestinationsProvider = StreamProvider<List<Destination>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamRecommendedDestinations();
});

/// Provider for active trips
final activeTripsProvider = Provider<List<Trip>>((ref) {
  final tripsAsync = ref.watch(userTripsProvider);
  return tripsAsync.maybeWhen(
    data: (trips) {
      final now = DateTime.now();
      return trips
          .where((trip) => !trip.isArchived && trip.endDate.isAfter(now))
          .toList();
    },
    orElse: () => [],
  );
});
