import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/core/providers/infrastructure_providers.dart';
import 'package:travel_genie/features/trip/models/trip.dart';

import 'trip_cover_image.dart';
import 'trip_details.dart';

/// Widget that displays a single trip card
class TripCard extends ConsumerWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ref
              .read(analyticsServiceProvider)
              .logViewItinerary(tripId: trip.id, destination: trip.title);
          // Navigate to trip details page
          context.push('/trip/${trip.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip image
            TripCoverImage(trip: trip),

            // Trip details
            TripDetails(trip: trip),
          ],
        ),
      ),
    );
  }
}
