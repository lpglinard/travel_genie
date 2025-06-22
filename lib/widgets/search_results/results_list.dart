import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import '../../providers/search_results_provider.dart';
import 'search_result_card.dart';

class ResultsList extends ConsumerStatefulWidget {
  const ResultsList({
    super.key,
    required this.query,
  });

  final String query;

  @override
  ConsumerState<ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends ConsumerState<ResultsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final resultsState = ref.read(searchResultsProvider);

      // Only load more if we have a non-empty nextPageToken and we're not already loading
      // If nextPageToken is null, it means there are no more pages to fetch
      if (resultsState.nextPageToken != null && 
          resultsState.nextPageToken!.isNotEmpty && 
          !resultsState.isLoadingMore && 
          !resultsState.isLoading) {
        log('Reached end of list, loading more results');
        ref.read(searchResultsProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: list.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            final place = list[index];
            return SearchResultCard(
              place: place,
              index: index,
              query: widget.query,
            );
          },
        ),
        if (resultsState.isLoadingMore)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
