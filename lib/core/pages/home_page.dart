import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/core/providers/home_providers.dart';
import 'package:travel_genie/core/widgets/home/active_trip_section.dart';
import 'package:travel_genie/core/widgets/home/gamification_progress_section.dart';
import 'package:travel_genie/core/widgets/home/greeting_section.dart';
import 'package:travel_genie/core/widgets/home/home_app_bar.dart';
import 'package:travel_genie/core/widgets/home/popular_destinations_section.dart';
import 'package:travel_genie/core/widgets/home/recommended_destinations_section.dart';
import 'package:travel_genie/core/widgets/home/search_section.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedDestinationsAsync = ref.watch(
      recommendedDestinationsProvider,
    );
    final activeTrips = ref.watch(activeTripsProvider);

    return Scaffold(
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const GreetingSection(),
            const SizedBox(height: 16),
            // CTA Button for creating trip with AI
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/new-trip'),
                icon: const Icon(Icons.auto_awesome),
                label: Text(AppLocalizations.of(context).homeCtaButton),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).homeCtaSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const SearchSection(),
            const SizedBox(height: 24),
            if (activeTrips.isNotEmpty) ...[
              ActiveTripSection(trips: activeTrips),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 24),
            const GamificationProgressSection(),
            recommendedDestinationsAsync.when(
              data: (destinations) =>
                  RecommendedDestinationsSection(destinations: destinations),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text(
                AppLocalizations.of(context).errorGeneric(error.toString()),
              ),
            ),

            const SizedBox(height: 24),
            // Trending destinations independent of profile
            recommendedDestinationsAsync.when(
              data: (destinations) =>
                  PopularDestinationsSection(destinations: destinations),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
