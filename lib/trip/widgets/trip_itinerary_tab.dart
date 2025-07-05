import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/models/itinerary_day.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/providers/itinerary_providers.dart';
import 'package:travel_genie/providers/user_providers.dart';
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
            final dayDate = trip.startDate.add(Duration(days: day.dayNumber - 1));
            final weekdayFormatter = DateFormat('E'); // Short weekday (Mon, Tue, etc.)
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
              final updatedDay = day.copyWith(notes: textController.text.trim());
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
      builder: (context) => AddPlaceBottomSheet(
        tripId: tripId,
        dayId: day.id,
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
      onTap: () {
        // Navigate to place detail page
        context.push('/place/${place.placeId}', extra: place);
      },
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

/// Bottom sheet for adding places to a day
class AddPlaceBottomSheet extends ConsumerStatefulWidget {
  const AddPlaceBottomSheet({
    super.key,
    required this.tripId,
    required this.dayId,
  });

  final String tripId;
  final String dayId;

  @override
  ConsumerState<AddPlaceBottomSheet> createState() => _AddPlaceBottomSheetState();
}

class _AddPlaceBottomSheetState extends ConsumerState<AddPlaceBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the real PlacesService with locationBias
      final placesService = ref.read(placesServiceProvider);
      final locationBias = await _getLocationBiasForTrip();

      final results = await placesService.autocomplete(
        query,
        locationBias: locationBias,
        regionCode: 'br',
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.searchError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Gets locationBias for the trip to improve search results relevance
  /// Returns a circle bias centered on the trip's destination coordinates
  Future<Map<String, dynamic>?> _getLocationBiasForTrip() async {
    try {
      final tripService = ref.read(tripServiceProvider);
      final trip = await tripService.getTripWithDetails(widget.tripId);

      if (trip == null) {
        return null;
      }

      // First, try to use the trip's location field
      if (trip.location != null) {
        return {
          'circle': {
            'center': {
              'latitude': trip.location!.lat,
              'longitude': trip.location!.lng,
            },
            'radius': 20000.0,
          },
        };
      }

      // If location is not available, try locationGeopoint
      if (trip.locationGeopoint != null) {
        return {
          'circle': {
            'center': {
              'latitude': trip.locationGeopoint!.latitude,
              'longitude': trip.locationGeopoint!.longitude,
            },
            'radius': 20000.0,
          },
        };
      }

      return null; // No location bias if no coordinates available
    } catch (e) {
      // Log error but don't throw - gracefully degrade to no bias
      debugPrint('Error getting locationBias for trip: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.addPlace,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchPlacesHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _searchPlaces,
                ),
              ),
              const SizedBox(height: 16),
              // Search results
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.trim().isEmpty
                                  ? AppLocalizations.of(context)!.searchPlacesHint
                                  : AppLocalizations.of(context)!.noPlacesFound,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final placeName = _searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.place),
                                title: Text(placeName),
                                trailing: ElevatedButton(
                                  onPressed: () => _addPlaceToDay(placeName),
                                  child: Text(AppLocalizations.of(context)!.addToDay),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addPlaceToDay(String placeName) async {
    try {
      // Note: This is a simplified implementation
      // In a real app, you would create a proper Place object and add it to Firestore
      // For now, we'll just show a success message
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.placeAdded),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
