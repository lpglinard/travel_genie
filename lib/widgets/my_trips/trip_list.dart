import 'package:flutter/material.dart';
import 'package:travel_genie/widgets/my_trips/trip_card.dart';

import '../../models/trip.dart';

/// Widget that displays a list of trips
class TripList extends StatelessWidget {
  final List<Trip> trips;

  const TripList({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return TripCard(trip: trip);
      },
    );
  }
}
