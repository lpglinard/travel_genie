import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:travel_genie/features/trip/models/trip.dart';
import 'package:travel_genie/features/user/providers/user_providers.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import '../providers/trip_providers.dart';
import '../widgets/trip_cover_image.dart';
import '../widgets/trip_itinerary_tab.dart';
import '../widgets/trip_overview_content.dart';
import '../widgets/trip_participants_avatars.dart';

class TripDetailsPage extends ConsumerWidget {
  const TripDetailsPage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final participantsAsync = ref.watch(tripParticipantsProvider(tripId));
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tripDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/trips'),
          tooltip: AppLocalizations.of(context)!.navMyTrips,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () =>
                _shareTripWithAnalytics(context, ref, tripAsync.value),
            tooltip: AppLocalizations.of(context)!.shareTrip,
          ),
        ],
      ),
      body: tripAsync.when(
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
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (trip) {
          if (trip == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trip_origin,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.tripNotFound,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return DefaultTabController(
            length: 3,
            initialIndex: selectedTabIndex,
            child: Column(
              children: [
                // Cover Image with Trip Title
                TripCoverImage(trip: trip),

                // Date Range
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        ref.watch(tripDateRangeProvider(trip)),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Participants Avatars
                participantsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppLocalizations.of(context)!.errorLoadingParticipants,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  data: (participants) =>
                      TripParticipantsAvatars(participants: participants),
                ),

                // Tab Bar
                TabBar(
                  onTap: (index) {
                    ref.read(selectedTabIndexProvider.notifier).state = index;
                  },
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.tripOverview),
                    Tab(text: AppLocalizations.of(context)!.tripItineraryTab),
                    Tab(text: AppLocalizations.of(context)!.tripExplore),
                  ],
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    children: [
                      // Overview Tab
                      TripOverviewContent(
                        trip: trip,
                        participantsAsync: participantsAsync,
                      ),

                      // Itinerary Tab
                      TripItineraryTab(tripId: tripId),

                      // Explore Tab (placeholder)
                      Center(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.exploreContentComingSoon,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addParticipant(context, ref),
        backgroundColor: const Color(0xFF5B6EFF),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: AppLocalizations.of(context)!.addParticipant,
      ),
    );
  }

  void _shareTripWithAnalytics(
    BuildContext context,
    WidgetRef ref,
    Trip? trip,
  ) {
    if (trip == null) return;

    // Log trip sharing using Firebase standard share event
    ref
        .read(analyticsServiceProvider)
        .logShareItinerary(
          tripId: tripId,
          method: 'native_share',
          contentType: 'trip',
        );

    final shareText = '${trip.title}\n${trip.description}';
    Share.share(shareText, subject: AppLocalizations.of(context)!.shareTrip);
  }

  void _addParticipant(BuildContext context, WidgetRef ref) {
    // TODO: Implement add participant functionality
    // This would typically open a modal or navigate to a participant selection screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.addParticipant)),
    );
  }
}
