import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/itinerary_day.dart';
import '../models/place.dart';
import '../providers/itinerary_providers.dart';
import '../providers/trip_service_provider.dart';

class TripItineraryPage extends ConsumerWidget {
  final String tripId;

  const TripItineraryPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(itineraryDaysProvider(tripId));
    final savedPlacesAsync = ref.watch(savedPlacesProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Navigate back to the previous screen
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          // If can't pop, go to trips page
          GoRouter.of(context).go('/trips');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trip Itinerary'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                GoRouter.of(context).go('/trips');
              }
            },
          ),
        ),
        body: daysAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (days) {
            return ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Saved Places', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                savedPlacesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Erro ao carregar lugares salvos: $e'),
                  ),
                  data: (savedPlaces) => Column(
                    children: savedPlaces.map((place) => ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(place.displayName),
                      subtitle: Text(place.formattedAddress),
                    )).toList(),
                  ),
                ),
                const Divider(height: 32),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Itinerary Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ...days.map((day) {
                  final placesAsync = ref.watch(placesForDayProvider((tripId: tripId, dayId: day.id)));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text('Day ${days.indexOf(day) + 1} - ${_formatDate(day.date)}'),
                      ),
                      placesAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: LinearProgressIndicator(),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Erro ao carregar lugares do dia: $e'),
                        ),
                        data: (places) => Column(
                          children: places.map((place) => ListTile(
                            leading: const Icon(Icons.place),
                            title: Text(place.displayName),
                            subtitle: Text(place.formattedAddress),
                          )).toList(),
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<ItineraryListItem> buildItineraryList({
    required List<Place> savedPlaces,
    required List<ItineraryDay> days,
    required Map<String, List<Place>> placesByDay,
  }) {
    final items = <ItineraryListItem>[];

    // Adiciona os lugares salvos
    for (final place in savedPlaces) {
      items.add(SavedPlaceItem(place));
    }

    // Adiciona os dias e seus lugares
    for (final day in days) {
      items.add(DayHeaderItem(day));

      final places = placesByDay[day.id] ?? [];
      for (final place in places) {
        items.add(DayPlaceItem(place, day.id));
      }
    }

    return items;
  }
}
sealed class ItineraryListItem {}

class SavedPlaceItem extends ItineraryListItem {
  final Place place;
  SavedPlaceItem(this.place);
}

class DayHeaderItem extends ItineraryListItem {
  final ItineraryDay day;
  DayHeaderItem(this.day);
}

class DayPlaceItem extends ItineraryListItem {
  final Place place;
  final String dayId;
  DayPlaceItem(this.place, this.dayId);
}