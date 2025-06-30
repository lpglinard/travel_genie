import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/destination.dart';
import '../services/firestore_service.dart';
import '../widgets/home/greeting_section.dart';
import '../widgets/home/hero_image.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/popular_destinations_section.dart';
import '../widgets/home/search_section.dart';
import '../providers/user_providers.dart';
import '../providers/trip_service_provider.dart';
import '../providers/itinerary_providers.dart';
import '../services/profile_service.dart';
import '../models/badge.dart';
import '../models/challenge.dart';
import '../models/trip.dart';
import '../l10n/app_localizations.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

final recommendedDestinationsProvider = StreamProvider<List<Destination>>((
  ref,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamRecommendedDestinations();
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const heroImage = 'images/odsy_main.png';
    final recommendedDestinationsAsync = ref.watch(recommendedDestinationsProvider);

    return Scaffold(
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroHeader(imagePath: heroImage),
            const SizedBox(height: 24),
            const SearchSection(),
            const SizedBox(height: 24),
            _ActiveTripSection(),
            const SizedBox(height: 24),
            recommendedDestinationsAsync.when(
              data: (destinations) => PopularDestinationsSection(
                destinations: destinations,
                title: AppLocalizations.of(context).homeRecommendedTitle,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Text('Error loading destinations: $error'),
            ),
            const SizedBox(height: 24),
            recommendedDestinationsAsync.when(
              data: (destinations) => PopularDestinationsSection(
                destinations: destinations,
                title: AppLocalizations.of(context).homePopularTitle,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            const _TravelerProgressSection(),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends ConsumerWidget {
  const _HeroHeader({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        HeroImage(imagePath: imagePath, borderRadius: 12),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GreetingSection(),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => context.go('/create-trip'),
                icon: const Icon(Icons.auto_awesome),
                label: Text(l10n.homeHeroCta),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.homeHeroSubtext,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveTripSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(userTripsProvider);
    final l10n = AppLocalizations.of(context);

    return tripsAsync.when(
      data: (trips) {
        final active = trips.firstWhere(
          (t) => !t.isArchived && t.endDate.isAfter(DateTime.now()),
          orElse: () => Trip(
            id: '',
            title: '',
            description: '',
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            coverImageUrl: '',
            userId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        if (active.id.isEmpty) return const SizedBox.shrink();

        final itineraryAsync = ref.watch(itineraryDaysProvider(active.id));
        return itineraryAsync.when(
          data: (days) {
            int planned = 0;
            for (final day in days) {
              final places = ref
                  .watch(
                    placesForDayProvider((tripId: active.id, dayId: day.id)),
                  )
                  .maybeWhen(data: (p) => p.length, orElse: () => 0);
              if (places > 0) planned++;
            }
            final progressText =
                '$planned de ${days.length} ${l10n.daysPlanned}';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeActiveTripTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(active.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(progressText),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.go('/trip/${active.id}'),
                        child: Text(l10n.homeContinuePlanning),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TravelerProgressSection extends ConsumerWidget {
  const _TravelerProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final profileService = ref.watch(profileServiceProvider);
    final l10n = AppLocalizations.of(context);

    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<Challenge>>(
      stream: profileService.getActiveChallenges(user.uid),
      builder: (context, challengeSnapshot) {
        if (challengeSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final challenges = challengeSnapshot.data ?? [];
        if (challenges.isEmpty) return const SizedBox.shrink();
        final challenge = challenges.first;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeProgressTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(challenge.title,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: challenge.progressPercentage),
              ],
            ),
          ),
        );
      },
    );
  }
}
