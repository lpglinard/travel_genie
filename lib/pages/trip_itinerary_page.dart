
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../models/itinerary_day.dart';
import '../models/place.dart';
import '../models/drag_drop_models.dart';
import '../providers/itinerary_providers.dart';
import '../providers/trip_service_provider.dart';
import '../services/itinerary_drag_drop_service.dart';
import '../widgets/trip_itinerary/saved_places_bin.dart';
import '../widgets/trip_itinerary/day_item.dart';

/// A page that displays and manages a trip's itinerary.
/// 
/// This page allows users to view and organize their trip itinerary by:
/// - Viewing saved places that can be added to days
/// - Organizing places within specific days via drag-and-drop
/// - Reordering places within days
/// - Moving places between different days
/// 
/// The page uses extracted widgets and services for better maintainability:
/// - [SavedPlacesBin] for displaying draggable saved places
/// - [DayItem] for displaying individual itinerary days
/// - [ItineraryDragDropService] for handling drag-and-drop business logic
class TripItineraryPage extends ConsumerWidget {
  /// The ID of the trip whose itinerary is being displayed
  final String tripId;

  /// Creates a new [TripItineraryPage].
  /// 
  /// [tripId] is required and identifies the trip whose itinerary to display.
  const TripItineraryPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(itineraryDaysProvider(tripId));
    final savedPlacesAsync = ref.watch(savedPlacesProvider);
    final l10n = AppLocalizations.of(context)!;

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
          title: Text(
            l10n.tripItinerary, 
            style: Theme.of(context).appBarTheme.titleTextStyle
          ),
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
          error: (e, _) => Center(
            child: Text(l10n.errorGeneric(e.toString()))
          ),
          data: (days) {
            return savedPlacesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(l10n.errorLoadingSavedPlaces(e.toString()))
              ),
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
                          l10n.savedPlaces,
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
                            final dragDropService = ref.read(itineraryDragDropServiceProvider(tripId));
                            await dragDropService.handlePlaceDrop(
                              data: data,
                              targetDayId: day.id,
                              insertIndex: insertIndex,
                              currentPlaces: places,
                            );
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

}
