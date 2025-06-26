import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/trip_service_provider.dart';
import '../widgets/my_trips/empty_trip_state.dart';
import '../widgets/my_trips/trip_list.dart';

/// Main page for displaying user's trips
class MyTripsPage extends ConsumerWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(userTripsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.navMyTrips)),
      body: SafeArea(
        child: tripsAsync.when(
          data: (trips) =>
              trips.isEmpty ? const EmptyTripState() : TripList(trips: trips),
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
}
