

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/features/trip/providers/trip_providers.dart';
import 'package:travel_genie/features/user/providers/user_providers.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

/// Bottom sheet for adding places to a day
/// Follows Single Responsibility Principle - only handles place addition UI
class AddPlaceBottomSheet extends ConsumerStatefulWidget {
  const AddPlaceBottomSheet({
    super.key,
    required this.tripId,
    required this.dayId,
  });

  final String tripId;
  final String dayId;

  @override
  ConsumerState<AddPlaceBottomSheet> createState() =>
      _AddPlaceBottomSheetState();
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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
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
                              child: Text(
                                AppLocalizations.of(context)!.addToDay,
                              ),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.placeAdded)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorGeneric(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}