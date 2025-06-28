import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/destination.dart';
import '../services/firestore_service.dart';
import '../widgets/home/greeting_section.dart';
import '../widgets/home/hero_image.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/popular_destinations_section.dart';
import '../widgets/home/search_section.dart';

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
    final recommendedDestinationsAsync = ref.watch(
      recommendedDestinationsProvider,
    );

    return Scaffold(
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const HeroImage(imagePath: heroImage),
            const SizedBox(height: 16),
            const GreetingSection(),
            const SizedBox(height: 12),
            const SearchSection(),
            const SizedBox(height: 24),
            recommendedDestinationsAsync.when(
              data: (destinations) =>
                  PopularDestinationsSection(destinations: destinations),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Text('Error loading destinations: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
