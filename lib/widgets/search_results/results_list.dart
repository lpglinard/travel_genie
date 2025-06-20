import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import '../../providers/search_results_provider.dart';
import 'search_result_card.dart';

class ResultsList extends ConsumerWidget {
  const ResultsList({
    super.key,
    required this.query,
  });

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsState = ref.watch(searchResultsProvider);

    // Show loading indicator for initial load
    if (resultsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error if there is one
    if (resultsState.error != null) {
      return Center(
        child: Text(
          'Error: ${resultsState.error}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    final list = resultsState.places;

    // Show no results message if list is empty
    if (list.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noResults,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final place = list[index];
        return SearchResultCard(
          place: place,
          index: index,
          query: query,
        );
      },
    );
  }
}
