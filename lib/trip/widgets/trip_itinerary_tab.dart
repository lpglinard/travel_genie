import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/models/itinerary_day.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/providers/itinerary_providers.dart';
import 'package:travel_genie/trip/providers/trip_providers.dart';

/// Widget that displays the itinerary tab content as a simple list of itinerary days
class TripItineraryTab extends ConsumerWidget {
  const TripItineraryTab({
    super.key,
    required this.tripId,
  });

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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
              child: ExpandableDayTile(
                day: day,
                tripId: tripId,
              ),
            );
          },
        );
      },
    );
  }
}

/// Expandable widget that displays a single itinerary day with places
class ExpandableDayTile extends ConsumerWidget {
  const ExpandableDayTile({
    super.key,
    required this.day,
    required this.tripId,
  });

  final ItineraryDay day;
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesForDayProvider((
      tripId: tripId,
      dayId: day.id,
    )));
    final tripAsync = ref.watch(tripDetailsProvider(tripId));

    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${day.dayNumber}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: tripAsync.when(
          loading: () => Text(
            'Day ${day.dayNumber}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          error: (_, __) => Text(
            'Day ${day.dayNumber}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          data: (trip) {
            if (trip == null) {
              return Text(
                'Day ${day.dayNumber}',
                style: Theme.of(context).textTheme.titleMedium,
              );
            }

            // Calculate the actual date for this day
            final dayDate = trip.startDate.add(Duration(days: day.dayNumber - 1));
            final weekdayFormatter = DateFormat('E'); // Short weekday (Mon, Tue, etc.)
            final dateFormatter = DateFormat('d/M'); // Day/Month format

            return Text(
              '${weekdayFormatter.format(dayDate)}, ${dateFormatter.format(dayDate)}',
              style: Theme.of(context).textTheme.titleMedium,
            );
          },
        ),
        subtitle: placesAsync.when(
          loading: () => Text(
            'Loading places...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          error: (_, __) => Text(
            'Error loading places',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          data: (places) => Text(
            places.isEmpty
                ? 'No places yet'
                : '${places.length} place${places.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        children: [
          placesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading places',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (places) {
              if (places.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No places yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort places by orderInDay
              final sortedPlaces = List<Place>.from(places)
                ..sort((a, b) => a.orderInDay.compareTo(b.orderInDay));

              return Column(
                children: sortedPlaces.map((place) => PlaceTile(place: place)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget that displays a single place in the itinerary
class PlaceTile extends StatelessWidget {
  const PlaceTile({
    super.key,
    required this.place,
  });

  final Place place;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          _getPlaceIcon(place.category.id.toString()),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        place.displayName,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (place.formattedAddress.isNotEmpty)
            Text(
              place.formattedAddress,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          Row(
            children: [
              if (place.rating != null) ...[
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  '${place.rating!.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                if (place.userRatingCount != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${place.userRatingCount})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
              if (place.rating != null && place.estimatedDurationMinutes != null)
                const SizedBox(width: 12),
              if (place.estimatedDurationMinutes != null) ...[
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${place.estimatedDurationMinutes}min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPlaceIcon(String categoryId) {
    switch (categoryId) {
      case 'restaurant':
        return Icons.restaurant;
      case 'tourist_attraction':
        return Icons.attractions;
      case 'lodging':
        return Icons.hotel;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.theater_comedy;
      case 'transportation':
        return Icons.directions_transit;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'finance':
        return Icons.account_balance;
      case 'government':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }
}
