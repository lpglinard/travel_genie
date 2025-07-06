import 'package:flutter/material.dart';
import 'package:travel_genie/features/trip/models/trip.dart';
import 'package:travel_genie/features/trip/widgets/my_trips/placeholder_content.dart';

/// Widget that displays a placeholder image for trips without a cover image
class TripPlaceholderImage extends StatelessWidget {
  final Trip trip;

  const TripPlaceholderImage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // Generate a color based on the trip ID to differentiate between trips
    final color = Colors.primaries[trip.id.hashCode % Colors.primaries.length];

    return Container(
      height: 150,
      color: color.withOpacity(0.3),
      child: Center(
        child: PlaceholderContent(trip: trip, color: color),
      ),
    );
  }
}
