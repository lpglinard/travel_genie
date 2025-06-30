import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/trip_service_provider.dart';
import '../widgets/login_required_dialog.dart';
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
          data: (trips) {
            if (trips.isEmpty) {
              // Check if user is authenticated
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  // User is not authenticated, show login dialog
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    LoginRequiredDialog.show(context);
                  });
                }
              } catch (e) {
                // Firebase might not be initialized, show login dialog
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  LoginRequiredDialog.show(context);
                });
              }
              return const EmptyTripState();
            }
            return TripList(trips: trips);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              AppLocalizations.of(context)!.errorLoadingTrips(error.toString()),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Check if user is authenticated before navigating to create trip
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              // Show login required dialog
              await LoginRequiredDialog.show(context);
              return;
            }
          } catch (e) {
            // Handle Firebase not initialized error - show login dialog
            await LoginRequiredDialog.show(context);
            return;
          }

          // Navigate to new trip creation page
          context.go('/new-trip');
        },
        child: const Icon(Icons.add),
        tooltip: AppLocalizations.of(context)!.createNewTrip,
      ),
    );
  }
}
