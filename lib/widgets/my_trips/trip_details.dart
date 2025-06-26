import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/trip.dart';
import 'trip_date_row.dart';

/// Widget that displays the trip details (title, dates, description)
class TripDetails extends StatelessWidget {
  final Trip trip;

  const TripDetails({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final startDate = dateFormat.format(trip.startDate);
    final endDate = dateFormat.format(trip.endDate);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip title
          Text(trip.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),

          // Trip dates
          TripDateRow(startDate: startDate, endDate: endDate),
          const SizedBox(height: 8),

          // Trip description
          if (trip.description.isNotEmpty)
            Text(
              trip.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 8),

          // Places count section removed to fix null safety issues
        ],
      ),
    );
  }
}
