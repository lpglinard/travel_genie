import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import '../providers/search_results_provider.dart';
import '../widgets/search_field.dart';
import '../widgets/search_results/results_list.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key, required this.query});

  final String query;

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Initialize with widget.query first to ensure it's not null
    _searchController = TextEditingController(text: widget.query);

    // Only perform a search if there are no existing results or if the query has changed
    Future.microtask(() {
      final currentResults = ref.read(searchResultsProvider);
      final lastQuery = ref.read(searchResultsProvider.notifier).lastQuery;

      // Update the search controller text with the last query if available
      if (lastQuery.isNotEmpty) {
        _searchController.text = lastQuery;
      }

      // Check if we need to perform a new search:
      // 1. If there are no existing results, or
      // 2. If the query is different from the last search query and not empty
      if (currentResults.places.isEmpty ||
          (widget.query != lastQuery && widget.query.isNotEmpty)) {
        ref.read(searchResultsProvider.notifier).search(widget.query);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Navigation is now handled by go_router

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchField(
                controller: _searchController,
                hintText: AppLocalizations.of(context)!.searchPlaceholder,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    ref.read(searchResultsProvider.notifier).search(value);
                  }
                },
              ),
            ),

            // Results list
            Expanded(child: ResultsList(query: _searchController.text)),
          ],
        ),
      ),
      // Bottom navigation is now handled by the ScaffoldWithNavBar in router.dart
    );
  }
}
