
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/itinerary_day.dart';
import '../models/place.dart';
import '../providers/itinerary_providers.dart';
import '../providers/trip_service_provider.dart';
// Helper class for drag-and-drop
class DraggedPlaceData {
  final Place place;
  final String? fromDayId;
  DraggedPlaceData({required this.place, this.fromDayId});
}

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

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Saved Places', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      SavedPlacesBin(
                        places: savedPlaces,
                      ),
                      const Divider(height: 32),
                      ...days.map((day) {
                        final places = placesByDay[day.id] ?? [];
                        return DayItem(
                          day: day,
                          places: places,
                          onPlaceAccepted: (DraggedPlaceData data, int insertIndex) async {
                            final tripService = ref.read(tripServiceProvider);
                            // Remove from previous day if needed
                            if (data.fromDayId != null && data.fromDayId != day.id) {
                              await tripService.removePlaceFromDay(
                                tripId: tripId,
                                dayId: data.fromDayId!,
                                place: data.place,
                              );
                            }
                            if (data.fromDayId == day.id) {
                              // Reorder within the same day
                              final oldIndex = places.indexWhere((p) => p == data.place);
                              if (oldIndex != -1 && oldIndex != insertIndex) {
                                await tripService.reorderPlacesWithinDay(
                                  tripId: tripId,
                                  dayId: day.id,
                                  oldIndex: oldIndex,
                                  newIndex: insertIndex,
                                );
                              }
                            } else if (!places.contains(data.place)) {
                              // Insert at the correct position
                              await tripService.addPlaceToDay(
                                tripId: tripId,
                                dayId: day.id,
                                place: data.place,
                                position: insertIndex,
                              );
                            }
                          },
                        );
                      }).toList(),
                    ],
                  ),
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

class SavedPlacesBin extends StatelessWidget {
  final List<Place> places;

  const SavedPlacesBin({
    super.key,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: places.map((place) {
          return LongPressDraggable<DraggedPlaceData>(
            data: DraggedPlaceData(place: place, fromDayId: null),
            feedback: Material(
              elevation: 6,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: ListTile(
                  tileColor: Colors.white,
                  title: Text(place.displayName),
                  subtitle: Text(place.formattedAddress),
                ),
              ),
            ),
            child: Chip(
              label: Text(place.displayName),
              avatar: const Icon(Icons.place_outlined, size: 18),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DayItem extends StatelessWidget {
  final ItineraryDay day;
  final List<Place> places;
  final Future<void> Function(DraggedPlaceData data, int insertIndex) onPlaceAccepted;

  const DayItem({
    super.key,
    required this.day,
    required this.places,
    required this.onPlaceAccepted,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Card(
        color: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('Day ${day.order ?? ''} - ${_formatDate(day.date)}'),
            ),
            // Insert DragTarget before first item
            _DragTargetSlot(
              onPlaceAccepted: (data) => onPlaceAccepted(data, 0),
            ),
            ...List.generate(places.length, (index) {
              final place = places[index];
              return Column(
                children: [
                  _PlaceDraggable(
                    place: place,
                    fromDayId: day.id,
                    child: ListTile(
                      key: ValueKey(place.displayName),
                      leading: const Icon(Icons.place),
                      title: Text(place.displayName),
                      subtitle: Text(place.formattedAddress),
                    ),
                  ),
                  _DragTargetSlot(
                    onPlaceAccepted: (data) => onPlaceAccepted(data, index + 1),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PlaceDraggable extends StatelessWidget {
  final Place place;
  final String fromDayId;
  final Widget child;
  const _PlaceDraggable({
    required this.place,
    required this.fromDayId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<DraggedPlaceData>(
      data: DraggedPlaceData(place: place, fromDayId: fromDayId),
      feedback: Material(
        elevation: 6,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: ListTile(
            tileColor: Colors.white,
            leading: const Icon(Icons.place),
            title: Text(place.displayName),
            subtitle: Text(place.formattedAddress),
          ),
        ),
      ),
      child: child,
      childWhenDragging: Opacity(opacity: 0.5, child: child),
    );
  }
}

class _DragTargetSlot extends StatelessWidget {
  final Future<void> Function(DraggedPlaceData data) onPlaceAccepted;
  const _DragTargetSlot({required this.onPlaceAccepted});

  @override
  Widget build(BuildContext context) {
    return DragTarget<DraggedPlaceData>(
      onWillAccept: (data) => data != null,
      onAccept: (data) async {
        await onPlaceAccepted(data);
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return Container(
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.shade200 : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }
}