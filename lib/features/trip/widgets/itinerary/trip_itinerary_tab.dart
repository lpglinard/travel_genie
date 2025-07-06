import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/features/trip/models/itinerary_day.dart';
import 'package:travel_genie/features/trip/providers/itinerary_providers.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

/// Widget that displays the itinerary tab content as a simple list of itinerary days
/// Follows Single Responsibility Principle - only handles itinerary tab display
class TripItineraryTab extends ConsumerWidget {
  const TripItineraryTab({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itineraryDaysAsync = ref.watch(itineraryDaysProvider(tripId));

    return itineraryDaysAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.errorLoadingTrip,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      data: (itineraryDays) {
        if (itineraryDays.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noItineraryYet,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.noItineraryDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Sort itinerary days by dayNumber
        final sortedDays = List<ItineraryDay>.from(itineraryDays)
          ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedDays.length,
          itemBuilder: (context, index) {
            final day = sortedDays[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${day.dayNumber}')),
                  title: Text('Day ${day.dayNumber}'),
                  subtitle: day.notes?.isNotEmpty == true
                      ? Text(day.notes!)
                      : const Text('No notes'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
