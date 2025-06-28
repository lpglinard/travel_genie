import 'package:flutter/material.dart';
import 'package:travel_genie/widgets/my_trips/trip_placeholder_image.dart';

import '../../models/trip.dart';

/// Widget that displays the trip cover image or a placeholder
class TripCoverImage extends StatelessWidget {
  final Trip trip;

  const TripCoverImage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return trip.coverImageUrl.isNotEmpty
        ? Image.network(
            trip.coverImageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return TripPlaceholderImage(trip: trip);
            },
          )
        : TripPlaceholderImage(trip: trip);
  }
}
