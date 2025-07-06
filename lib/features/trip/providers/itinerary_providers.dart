import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/features/place/models/place.dart';

import '../models/itinerary_day.dart';
import 'trip_providers.dart';

// StreamProvider para listar os dias da viagem
final itineraryDaysProvider = StreamProvider.family<List<ItineraryDay>, String>(
  (ref, tripId) {
    final tripService = ref.watch(tripServiceProvider);
    return tripService.streamItineraryDays(tripId);
  },
);

// StreamProvider para listar os lugares de um dia
final placesForDayProvider =
    StreamProvider.family<List<Place>, ({String tripId, String dayId})>((
      ref,
      key,
    ) {
      final tripService = ref.watch(tripServiceProvider);
      return tripService.streamPlacesForDay(
        tripId: key.tripId,
        dayId: key.dayId,
      );
    });
