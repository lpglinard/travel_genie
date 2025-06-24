
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
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
          title: Text('Trip Itinerary', style: Theme.of(context).appBarTheme.titleTextStyle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
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
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Saved Places', 
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SavedPlacesBin(
                        places: savedPlaces,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Divider(
                          height: 32,
                          thickness: 1,
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
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
    final dayFormat = DateFormat('EEEE'); // Full day name
    final dateFormat = DateFormat('d MMM yyyy'); // Day, month, year
    return '${dayFormat.format(date)}, ${dateFormat.format(date)}';
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
              elevation: 2,
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).brightness == Brightness.light 
                ? place.category.lightColor.withOpacity(0.7)
                : place.category.darkColor.withOpacity(0.7),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        place.category.icon, 
                        size: 24, 
                        color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.displayName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (place.formattedAddress.isNotEmpty)
                              Text(
                                place.formattedAddress,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.black.withOpacity(0.9),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                context.push('/place/${place.placeId}', extra: place);
              },
              child: Card(
                elevation: 0,
                color: Theme.of(context).brightness == Brightness.light 
                  ? place.category.lightColor.withOpacity(0.6)
                  : place.category.darkColor.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        place.category.icon, 
                        size: 18, 
                        color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          place.displayName,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

  String formatDayDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dayFormat = DateFormat('EEEE', locale); // Full day name
    final dateFormat = DateFormat('d MMM yyyy', locale); // Day, month, year
    return '${dayFormat.format(date)}, ${dateFormat.format(date)}';
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: Text(
                  formatDayDate(day.date, context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(day.summary ?? ''),
              ),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: ListTile(
                          key: ValueKey(place.displayName),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light
                                ? place.category.lightColor.withOpacity(0.15)
                                : place.category.darkColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              place.category.icon,
                              size: 24,
                              color: Theme.of(context).brightness == Brightness.light
                                ? place.category.lightColor
                                : place.category.darkColor,
                            ),
                          ),
                          title: Text(
                            place.displayName,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              place.formattedAddress,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          tileColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onTap: () {
                            context.push('/place/${place.placeId}', extra: place);
                          },
                        ),
                      ),
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
        elevation: 2,
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).brightness == Brightness.light 
          ? place.category.lightColor.withOpacity(0.7)
          : place.category.darkColor.withOpacity(0.7),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    place.category.icon, 
                    size: 24, 
                    color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (place.formattedAddress.isNotEmpty)
                        Text(
                          place.formattedAddress,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black.withOpacity(0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                    ],
                  ),
                ),
              ],
            ),
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isActive ? 32 : 16,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isActive 
                ? Theme.of(context).colorScheme.secondaryContainer 
                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),

            ),
            child: isActive 
              ? Center(
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                )
              : null,
          ),
        );
      },
    );
  }
}
