import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/place.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../providers/user_providers.dart';

/// Widget to display a placeholder image for trips without a cover image
class TripPlaceholderImage extends StatelessWidget {
  const TripPlaceholderImage({
    super.key,
    required this.trip,
  });

  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    // Generate a color based on the trip ID to differentiate between trips
    final color = trip != null
        ? Colors.primaries[trip!.id.hashCode % Colors.primaries.length]
        : Colors.blue;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape,
              size: 64,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              trip?.title ?? 'Trip Itinerary',
              style: TextStyle(
                color: color.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display a day section in the itinerary
class DaySection extends StatelessWidget {
  const DaySection({
    super.key,
    required this.dayNumber,
    required this.date,
  });

  final int dayNumber;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('EEEE, MMM d, yyyy');
    final dayString = dayFormat.format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day number and date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Day ${dayNumber + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dayString,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
        // Add a placeholder for activities
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: Text(
            'No activities planned for this day',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget to display day-by-day itinerary sections
class DayByDayItinerary extends StatelessWidget {
  const DayByDayItinerary({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    // Calculate the number of days in the trip
    final int numberOfDays = trip.endDate.difference(trip.startDate).inDays + 1;

    // Create a list of widgets for each day
    List<Widget> daySections = [];

    // Create a section for each day
    for (int i = 0; i < numberOfDays; i++) {
      // Calculate the date for this day
      final dayDate = trip.startDate.add(Duration(days: i));

      // Add a section for this day
      daySections.add(DaySection(dayNumber: i, date: dayDate));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: daySections,
    );
  }
}

/// Widget to display empty trip state
class EmptyTripState extends StatelessWidget {
  const EmptyTripState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.map_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No places in your itinerary yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add places to your trip',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display trip details
class TripDetails extends StatelessWidget {
  const TripDetails({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final startDate = dateFormat.format(trip.startDate);
    final endDate = dateFormat.format(trip.endDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trip.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            Text('$startDate - $endDate'),
          ],
        ),
        if (trip.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            trip.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

/// Widget to display the trip itinerary
class TripItineraryView extends StatelessWidget {
  const TripItineraryView({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Trip header with image
        if (trip.coverImageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              trip.coverImageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return TripPlaceholderImage(trip: trip);
              },
            ),
          )
        else
          TripPlaceholderImage(trip: trip),
        const SizedBox(height: 16),

        // Trip details
        TripDetails(trip: trip),
        const SizedBox(height: 24),

        // Itinerary section
        Text(
          'Itinerary',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        // If no places, show empty state
        if (trip.places.isEmpty)
          const EmptyTripState()
        else
          // Day-by-day itinerary sections
          DayByDayItinerary(trip: trip),
      ],
    );
  }
}

/// Widget to display empty saved places state
class EmptySavedPlacesState extends StatelessWidget {
  const EmptySavedPlacesState({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved places found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Save places while exploring to add them to your trips',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onBack,
            child: const Text('Back to Itinerary'),
          ),
        ],
      ),
    );
  }
}

/// Widget to display a saved place card
class SavedPlaceCard extends StatelessWidget {
  const SavedPlaceCard({
    super.key,
    required this.place,
    required this.onAddPlace,
  });

  final Place place;
  final Function(Place) onAddPlace;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
                width: 56,
                height: 56,
                color: Colors.grey[300],
                child: const Icon(Icons.place, color: Colors.grey),
              ),
        title: Text(place.displayName),
        subtitle: Text(
          place.formattedAddress,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add to trip',
          onPressed: () => onAddPlace(place),
        ),
        onTap: () => onAddPlace(place),
      ),
    );
  }
}

/// Widget to display saved places error state
class SavedPlacesErrorState extends StatelessWidget {
  const SavedPlacesErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Widget to display saved places
class SavedPlacesView extends StatelessWidget {
  const SavedPlacesView({
    super.key,
    required this.savedPlaces,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onBack,
    required this.onAddPlace,
  });

  final List<Place> savedPlaces;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final Function(Place) onAddPlace;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return SavedPlacesErrorState(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }

    if (savedPlaces.isEmpty) {
      return EmptySavedPlacesState(onBack: onBack);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Saved Places',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),

        // List of saved places
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: savedPlaces.length,
            itemBuilder: (context, index) {
              final place = savedPlaces[index];
              return SavedPlaceCard(
                place: place,
                onAddPlace: onAddPlace,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Widget to display the main content based on the current state
class TripItineraryContent extends StatelessWidget {
  const TripItineraryContent({
    super.key,
    required this.trip,
    required this.isLoading,
    required this.errorMessage,
    required this.showingSavedPlaces,
    required this.savedPlaces,
    required this.isLoadingSavedPlaces,
    required this.savedPlacesError,
    required this.onLoadSavedPlaces,
    required this.onToggleSavedPlaces,
    required this.onAddPlaceToTrip,
  });

  final Trip? trip;
  final bool isLoading;
  final String? errorMessage;
  final bool showingSavedPlaces;
  final List<Place> savedPlaces;
  final bool isLoadingSavedPlaces;
  final String? savedPlacesError;
  final VoidCallback onLoadSavedPlaces;
  final VoidCallback onToggleSavedPlaces;
  final Function(Place) onAddPlaceToTrip;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    if (trip == null) {
      return const Center(
        child: Text('Trip not found'),
      );
    }

    // Show saved places if the flag is set
    if (showingSavedPlaces) {
      return SavedPlacesView(
        savedPlaces: savedPlaces,
        isLoading: isLoadingSavedPlaces,
        errorMessage: savedPlacesError,
        onRetry: onLoadSavedPlaces,
        onBack: onToggleSavedPlaces,
        onAddPlace: onAddPlaceToTrip,
      );
    }

    // We've already checked that trip is not null
    return TripItineraryView(trip: trip!);
  }
}

class TripItineraryPage extends ConsumerStatefulWidget {
  const TripItineraryPage({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  ConsumerState<TripItineraryPage> createState() => _TripItineraryPageState();
}

class _TripItineraryPageState extends ConsumerState<TripItineraryPage> {
  Trip? _trip;
  bool _isLoading = true;
  String? _errorMessage;

  // Saved places state
  List<Place> _savedPlaces = [];
  bool _isLoadingSavedPlaces = false;
  bool _showingSavedPlaces = false;
  String? _savedPlacesError;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    try {
      final trip = await ref.read(tripsProvider.notifier).getTrip(widget.tripId);
      if (mounted) {
        setState(() {
          _trip = trip;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load trip: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Load saved places for the current user
  Future<void> _loadSavedPlaces() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _savedPlacesError = 'User not logged in';
        _isLoadingSavedPlaces = false;
      });
      return;
    }

    setState(() {
      _isLoadingSavedPlaces = true;
      _savedPlacesError = null;
    });

    try {
      // Get the FirestoreService instance
      final firestoreService = ref.read(firestoreServiceProvider);

      // Listen to the stream of saved places
      firestoreService.streamSavedPlacesAsPlaces(user.uid).listen(
        (places) {
          if (mounted) {
            setState(() {
              _savedPlaces = places;
              _isLoadingSavedPlaces = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _savedPlacesError = 'Failed to load saved places: $error';
              _isLoadingSavedPlaces = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _savedPlacesError = 'Failed to load saved places: $e';
          _isLoadingSavedPlaces = false;
        });
      }
    }
  }

  // Toggle showing saved places
  void _toggleSavedPlaces() {
    final newState = !_showingSavedPlaces;
    setState(() {
      _showingSavedPlaces = newState;
    });

    // Load saved places if we're showing them and they haven't been loaded yet
    if (newState && _savedPlaces.isEmpty && !_isLoadingSavedPlaces) {
      _loadSavedPlaces();
    }
  }

  // Add a saved place to the trip
  Future<void> _addPlaceToTrip(Place place) async {
    if (_trip == null) return;

    try {
      await ref.read(tripsProvider.notifier).addPlaceToTrip(widget.tripId, place);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${place.displayName} to your trip'),
            duration: const Duration(seconds: 2),
          ),
        );

        // Reload the trip to show the new place
        _loadTrip();

        // Hide the saved places view
        setState(() {
          _showingSavedPlaces = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add place: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_trip?.title ?? 'Trip Itinerary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/trips'),
        ),
      ),
      body: SafeArea(
        child: TripItineraryContent(
          trip: _trip,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          showingSavedPlaces: _showingSavedPlaces,
          savedPlaces: _savedPlaces,
          isLoadingSavedPlaces: _isLoadingSavedPlaces,
          savedPlacesError: _savedPlacesError,
          onLoadSavedPlaces: _loadSavedPlaces,
          onToggleSavedPlaces: _toggleSavedPlaces,
          onAddPlaceToTrip: _addPlaceToTrip,
        ),
      ),
      floatingActionButton: _trip != null
          ? FloatingActionButton(
              onPressed: _toggleSavedPlaces,
              child: const Icon(Icons.add),
              tooltip: 'Add Place to Itinerary',
            )
          : null,
    );
  }
}
