import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/destination.dart';
import '../../providers/autocomplete_provider.dart';
import '../../providers/user_providers.dart';

class PopularDestinationsSection extends StatelessWidget {
  const PopularDestinationsSection({
    super.key,
    required this.destinations,
    required this.title,
  });

  final List<Destination> destinations;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final dest = destinations[index];
              return _DestinationItem(destination: dest);
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: destinations.length,
          ),
        ),
      ],
    );
  }
}

class _DestinationItem extends ConsumerWidget {
  const _DestinationItem({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref
            .read(analyticsServiceProvider)
            .logButtonTap(
              buttonName: 'popular_destination',
              screenName: 'home',
              context: destination.name,
            );
        // Clear autocomplete suggestions
        ref.read(autocompleteProvider.notifier).search('');
        // Navigate to explore page with destination name as query
        context.go('/explore?query=${destination.name}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              destination.imageUrl,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 4),
          Text(destination.name, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
