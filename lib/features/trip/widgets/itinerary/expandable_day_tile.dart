

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travel_genie/features/place/models/place.dart';
import 'package:travel_genie/features/trip/models/itinerary_day.dart';
import 'package:travel_genie/features/trip/providers/itinerary_providers.dart';
import 'package:travel_genie/features/trip/providers/trip_providers.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import 'place_tile.dart';
import 'add_place_bottom_sheet.dart';

/// Expandable widget that displays a single itinerary day with places
/// Follows Single Responsibility Principle - only handles day tile display and interactions
class ExpandableDayTile extends ConsumerWidget {
  const ExpandableDayTile({super.key, required this.day, required this.tripId});

  final ItineraryDay day;
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(
      placesForDayProvider((tripId: tripId, dayId: day.id)),
    );
    final tripAsync = ref.watch(tripDetailsProvider(tripId));

    return Card(
      elevation: 2,
      child: ExpansionTile(
        key: Key(day.id),
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
            final dayDate = trip.startDate.add(
              Duration(days: day.dayNumber - 1),
            );
            final weekdayFormatter = DateFormat(
              'E',
            ); // Short weekday (Mon, Tue, etc.)
            final dateFormatter = DateFormat('d/M'); // Day/Month format

            return Text(
              '${weekdayFormatter.format(dayDate)}, ${dateFormatter.format(dayDate)}',
              style: Theme.of(context).textTheme.titleMedium,
            );
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            placesAsync.when(
              loading: () => Text(
                AppLocalizations.of(context)!.noResults,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              error: (_, __) => Text(
                AppLocalizations.of(context)!.errorGeneric('loading places'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              data: (places) => Text(
                places.isEmpty
                    ? AppLocalizations.of(context)!.noPlacesForDay
                    : AppLocalizations.of(context)!.placesCount(places.length),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            if (day.notes != null && day.notes!.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.hasNotes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                day.notes != null && day.notes!.isNotEmpty
                    ? Icons.note
                    : Icons.note_add,
                color: day.notes != null && day.notes!.isNotEmpty
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              onPressed: () => _showNotesDialog(context, ref),
              tooltip: day.notes != null && day.notes!.isNotEmpty
                  ? AppLocalizations.of(context)!.editNote
                  : AppLocalizations.of(context)!.addNote,
            ),
            IconButton(
              icon: Icon(
                Icons.add_location,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              onPressed: () => _showAddPlaceDialog(context, ref),
              tooltip: AppLocalizations.of(context)!.addPlace,
            ),
          ],
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No places yet',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
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
                children: sortedPlaces
                    .map((place) => PlaceTile(place: place))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController(text: day.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.dayNotes),
        content: TextField(
          controller: textController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.notePlaceholder,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          if (day.notes != null && day.notes!.isNotEmpty)
            TextButton(
              onPressed: () async {
                final tripService = ref.read(tripServiceProvider);
                final updatedDay = day.copyWith(notes: '');
                await tripService.updateItineraryDay(tripId, updatedDay);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.notesDeleted),
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.deleteNote),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final tripService = ref.read(tripServiceProvider);
              final updatedDay = day.copyWith(
                notes: textController.text.trim(),
              );
              await tripService.updateItineraryDay(tripId, updatedDay);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.notesSaved),
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.saveNote),
          ),
        ],
      ),
    );
  }

  void _showAddPlaceDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddPlaceBottomSheet(tripId: tripId, dayId: day.id),
    );
  }
}