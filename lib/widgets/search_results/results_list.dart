import 'dart:developer';

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

    // Create a scroll controller to detect when user reaches the end
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      // Check if we're at the bottom of the list
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        // If we have more results and we're not already loading more, load more
        if (resultsState.hasMoreResults && !resultsState.isLoadingMore) {
          log('ResultsList - Reached end of list, loading more results');
          ref.read(searchResultsProvider.notifier).loadMore();
        }
      }
    });

    return ListView.builder(
      controller: scrollController,
      itemCount: list.length + (resultsState.isLoadingMore || resultsState.hasMoreResults ? 1 : 0),
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end if loading more
        if (index == list.length) {
          if (resultsState.isLoadingMore) {
            log('ResultsList - Showing loading indicator at the end of the list');
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            // This is a spacer for when we have more results but aren't loading yet
            return const SizedBox(height: 16.0);
          }
        }

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