import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

import '../l10n/app_localizations.dart';
import '../user_providers.dart';
import '../models/destination.dart';
import '../providers/autocomplete_provider.dart';

final _destinations = [
  Destination('Paris',
      'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=400&q=60'),
  Destination('Caribbean Beaches',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=60'),
  Destination('Patagonia',
      'https://images.unsplash.com/photo-1575819453111-abb276cd4973?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?auto=format&fit=crop&w=400&q=60'),
];

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final userData = ref.watch(userDataProvider).valueOrNull;
    String greeting = AppLocalizations.of(context).greeting;
    if (user != null && !user.isAnonymous) {
      final name = userData?.name ?? user.displayName;
      if (name != null && name.isNotEmpty) {
        greeting = '${AppLocalizations.of(context).greeting}, $name';
      }
    }
    const heroImage =
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=60';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(heroImage, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) {
                log('HomePage search field changed: ' + value);
                ref.read(autocompleteProvider.notifier).search(value);
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchPlaceholder,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surface.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            () {
              final suggestions = ref.watch(autocompleteProvider);
              return suggestions.maybeWhen(
                data: (list) => list.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        children:
                            list.map((s) => ListTile(title: Text(s))).toList(),
                      ),
                orElse: () => const SizedBox.shrink(),
              );
            }(),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).popularDestinations,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final dest = _destinations[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(dest.imageUrl,
                            width: 120, height: 100, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 4),
                      Text(dest.name),
                    ],
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: _destinations.length,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context).navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: AppLocalizations.of(context).navExplore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: AppLocalizations.of(context).navMyTrips,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: AppLocalizations.of(context).navGroups,
          ),
        ],
      ),
    );
  }
}
