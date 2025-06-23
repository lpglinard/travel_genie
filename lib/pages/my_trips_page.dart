import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/trip.dart';
import '../services/trip_provider.dart';

/// Main page for displaying user's trips
class MyTripsPage extends ConsumerWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(_tripsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navMyTrips),
      ),
      body: SafeArea(
        child: tripsAsync.when(
          data: (trips) => _buildContent(context, trips),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error loading trips: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new trip creation page
          context.go('/new-trip');
        },
        child: const Icon(Icons.add),
        tooltip: 'Create New Trip',
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Trip> trips) {
    if (trips.isEmpty) {
      return _buildEmptyState(context);
    }
    return _buildTripList(context, trips);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.map_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No trips saved yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your saved trips will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to explore page
              context.go('/explore');
            },
            icon: const Icon(Icons.search),
            label: const Text('Explore Destinations'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(BuildContext context, List<Trip> trips) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(context, trip);
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final startDate = dateFormat.format(trip.startDate);
    final endDate = dateFormat.format(trip.endDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to trip itinerary page
          context.go('/trip/${trip.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip image
            trip.coverImageUrl.isNotEmpty
              ? Image.network(
                  trip.coverImageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage(context, trip);
                  },
                )
              : _buildPlaceholderImage(context, trip),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip title
                  Text(
                    trip.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  // Trip dates
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text('$startDate - $endDate'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Trip description
                  if (trip.description.isNotEmpty)
                    Text(
                      trip.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 8),

                  // Places count section removed to fix null safety issues
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Creates a placeholder image for trips without a cover image
  Widget _buildPlaceholderImage(BuildContext context, Trip trip) {
    // Generate a color based on the trip ID to differentiate between trips
    final color = Colors.primaries[trip.id.hashCode % Colors.primaries.length];

    return Container(
      height: 150,
      color: color.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape,
              size: 50,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              trip.title.isNotEmpty ? trip.title : 'Trip',
              style: TextStyle(
                color: color.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
