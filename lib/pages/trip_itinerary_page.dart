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
                ...days.map((day) => ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Day ${days.indexOf(day) + 1} - ${_formatDate(day.date)}'),
                )),
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
}
