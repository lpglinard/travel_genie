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
            return savedPlacesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro ao carregar lugares salvos: $e')),
              data: (savedPlaces) {
                final placesByDay = {
                  for (final day in days)
                    day.id: ref.watch(placesForDayProvider((tripId: tripId, dayId: day.id))).maybeWhen(
                      data: (places) => places,
                      orElse: () => <Place>[],                    )
                };

                final listItems = buildItineraryList(
                  savedPlaces: savedPlaces,
                  days: days,
                  placesByDay: placesByDay,
                );

                return ListView.builder(
                  itemCount: listItems.length,
                  itemBuilder: (context, index) {
                    final item = listItems[index];

                    if (item is SavedPlaceItem) {
                      return LongPressDraggable<Place>(
                        data: item.place,
                        feedback: Material(
                          elevation: 6,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: ListTile(
                              tileColor: Colors.white,
                              title: Text(item.place.displayName),
                              subtitle: Text(item.place.formattedAddress),
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(item.place.displayName),
                          subtitle: Text(item.place.formattedAddress),
                        ),
                      );
                    } else if (item is DayHeaderItem) {
                      return DragTarget<Place>(
                        onWillAccept: (place) => true,
                        onAccept: (place) async {
                          final tripService = ref.read(tripServiceProvider);
                          await tripService.addPlaceToDay(
                            tripId: tripId,
                            dayId: item.day.id,
                            place: place,
                          );
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isActive = candidateData.isNotEmpty;
                          return ListTile(
                            tileColor: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                            leading: const Icon(Icons.calendar_today),
                            title: Text('Day ${days.indexOf(item.day) + 1} - ${_formatDate(item.day.date)}'),
                          );
                        },
                      );
                    } else if (item is DayPlaceItem) {
                      return ListTile(
                        leading: const Icon(Icons.place),
                        title: Text(item.place.displayName),
                        subtitle: Text(item.place.formattedAddress),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
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