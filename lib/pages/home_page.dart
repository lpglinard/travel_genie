import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/destination.dart';
import '../widgets/home/greeting_section.dart';
import '../widgets/home/hero_image.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/popular_destinations_section.dart';
import '../widgets/home/search_section.dart';

List<Destination> _getDestinations(BuildContext context) {
  return [
    Destination(
      AppLocalizations.of(context).paris,
      'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=400&q=60',
    ),
    Destination(
      AppLocalizations.of(context).caribbeanBeaches,
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=60',
    ),
    Destination(
      AppLocalizations.of(context).patagonia,
      'https://images.unsplash.com/photo-1575819453111-abb276cd4973?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?auto=format&fit=crop&w=400&q=60',
    ),
  ];
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const heroImage = 'images/odsy_main.png';
    final destinations = _getDestinations(context);

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
            PopularDestinationsSection(destinations: destinations),
          ],
        ),
      ),
    );
  }
}
