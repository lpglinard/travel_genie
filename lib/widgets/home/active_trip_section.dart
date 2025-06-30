import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/trip.dart';
import '../../providers/itinerary_providers.dart';

class ActiveTripSection extends ConsumerWidget {
  const ActiveTripSection({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plannedDaysAsync = ref.watch(_plannedDaysProvider(trip.id));
    final totalDays = trip.endDate.difference(trip.startDate).inDays + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).homeActiveTripTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              trip.title,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            plannedDaysAsync.when(
              data: (planned) => Text(
                AppLocalizations.of(context)
                    .tripPlanningStatus(planned, totalDays),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/trip/${trip.id}'),
                child: Text(AppLocalizations.of(context).continuePlanning),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _plannedDaysProvider = FutureProvider.family<int, String>((ref, tripId) async {
  final days = await ref.read(itineraryDaysProvider(tripId).future);
  int planned = 0;
  for (final day in days) {
    final places =
        await ref.read(placesForDayProvider((tripId: tripId, dayId: day.id)).future);
    if (places.isNotEmpty) {
      planned++;
    }
  }
  return planned;
});
