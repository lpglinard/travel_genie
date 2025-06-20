import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/destination.dart';
import '../providers/autocomplete_provider.dart';
import '../providers/user_providers.dart';
import '../widgets/search_field.dart';

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

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController searchController;
  late List<Destination> _destinations;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    if (value.isNotEmpty) {
      log('Search form submitted with value: ' + value);
      ref.read(autocompleteProvider.notifier).search('');
      // Use go_router to navigate to the explore page with the query parameter
      context.go('/explore?query=$value');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final userData = ref.watch(userDataProvider).valueOrNull;
    String greeting = AppLocalizations.of(context).greeting;

    authState.whenData((user) {
      if (user != null && !user.isAnonymous) {
        final name = userData?.name ?? user.displayName;
        if (name != null && name.isNotEmpty) {
          greeting = '${AppLocalizations.of(context).greeting}, $name';
        }
      }
    });
    const heroImage = 'images/odsy_main.png';

    _destinations = _getDestinations(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).navHome),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              authState.whenData((user) {
                if (user != null && !user.isAnonymous) {
                  // Navigate to profile screen if user is authenticated and not anonymous
                  context.push('/profile');
                } else {
                  // Navigate to sign-in screen if user is anonymous
                  context.go('/signin');
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(heroImage, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(greeting, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Form(
              key: formKey,
              child: SearchField(
                controller: searchController,
                hintText: AppLocalizations.of(context).searchPlaceholder,
                onChanged: (value) {
                  log('HomePage search field changed: ' + value);
                  ref.read(autocompleteProvider.notifier).search(value);
                },
                onSubmitted: _submitSearch,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _submitSearch(searchController.text),
                ),
              ),
            ),
            () {
              final suggestions = ref.watch(autocompleteProvider);
              return suggestions.maybeWhen(
                data: (list) => list.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        children: list
                            .map(
                              (s) => ListTile(
                                title: Text(s),
                                onTap: () {
                                  searchController.text = s;
                                  _submitSearch(s);
                                },
                              ),
                            )
                            .toList(),
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
                        child: Image.network(
                          dest.imageUrl,
                          width: 120,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
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
    );
  }
}
