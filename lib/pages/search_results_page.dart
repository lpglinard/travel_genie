import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/config.dart';
import '../core/extensions/string_extension.dart';
import '../l10n/app_localizations.dart';
import '../providers/search_results_provider.dart';
import '../widgets/search_field.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key, required this.query});

  final String query;

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';

  List<String> _getCategories(BuildContext context) {
    return [
      AppLocalizations.of(context).categoryAll,
      AppLocalizations.of(context).categoryAttractions,
      AppLocalizations.of(context).categoryRestaurants,
      AppLocalizations.of(context).categoryHotels,
    ];
  }

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
        log('SearchResultsPage - Performing initial search for query: ${widget.query}');
        ref.read(searchResultsProvider.notifier).search(widget.query);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    // In a real implementation, you would filter the results based on the category
    // For now, we'll just update the UI to show the selected category
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize selected category with localized value
    if (_selectedCategory == 'All') {
      _selectedCategory = AppLocalizations.of(context).categoryAll;
    }
  }

  // Navigation is now handled by go_router

  @override
  Widget build(BuildContext context) {
    final resultsState = ref.watch(searchResultsProvider);

    // Log the current state for debugging
    log('SearchResultsPage - Building with state: isLoading=${resultsState.isLoading}, ' +
        'isLoadingMore=${resultsState.isLoadingMore}, ' +
        'places=${resultsState.places.length}, ' +
        'hasMoreResults=${resultsState.hasMoreResults}');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchField(
                controller: _searchController,
                hintText: AppLocalizations.of(context).searchPlaceholder,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    ref.read(searchResultsProvider.notifier).search(value);
                  }
                },
              ),
            ),

            // Category filters
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _getCategories(context).length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final category = _getCategories(context)[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _filterByCategory(category),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: isSelected ? 2 : 0,
                      ),
                      child: Text(category),
                    ),
                  );
                },
              ),
            ),

            // Results list
            Expanded(
              child: Builder(
                builder: (context) {
                  // Show loading indicator for initial load
                  if (resultsState.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Show error if there is one
                  if (resultsState.error != null) {
                    return Center(
                      child: Text('Error: ${resultsState.error}'),
                    );
                  }

                  final list = resultsState.places;

                  // Show no results message if list is empty
                  if (list.isEmpty) {
                    return Center(
                      child: Text(AppLocalizations.of(context).noResults),
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
                        log('SearchResultsPage - Reached end of list, loading more results');
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
                          log('SearchResultsPage - Showing loading indicator at the end of the list');
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

                      // Get the first type or use a default
                      String placeType = place.types.isNotEmpty
                          ? place.types.first.replaceAll('_', ' ').capitalize()
                          : AppLocalizations.of(context).defaultPlaceType;

                      // Extract location from formatted address (simplified)
                      String location =
                          place.formattedAddress.split(',').length > 1
                          ? place.formattedAddress.split(',')[1].trim()
                          : '';

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            // Navigate to place detail using go_router with push
                            context.push(
                              '/place/${place.placeId}?query=${Uri.encodeComponent(_searchController.text)}',
                              extra: {'place': place, 'heroTagIndex': index},
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image section
                              SizedBox(
                                width: double.infinity,
                                height: 200, // Fixed height for all images
                                child: place.photos.isNotEmpty
                                    ? Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      12,
                                                    ),
                                                    topRight: Radius.circular(
                                                      12,
                                                    ),
                                                  ),
                                              child: Hero(
                                                tag:
                                                    'place-image-${place.placeId}-$index',
                                                child: CachedNetworkImage(
                                                  imageUrl: place.photos.first
                                                      .urlWithKey(
                                                        googlePlacesApiKey,
                                                      ),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                        child: const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Container(
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          size: 40,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (place
                                              .photos
                                              .first
                                              .authorAttributions
                                              .isNotEmpty)
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              left: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 8,
                                                    ),
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  ).photoBy(
                                                    place
                                                        .photos
                                                        .first
                                                        .authorAttributions
                                                        .map(
                                                          (attr) =>
                                                              attr.displayName,
                                                        )
                                                        .join(", "),
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                  textAlign: TextAlign.end,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                        ],
                                      )
                                    : Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.image,
                                          size: 40,
                                        ),
                                      ),
                              ),

                              // Text content section
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category with icon and background color
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? place.category.lightColor
                                                : place.category.darkColor,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                place.category.icon,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                place.category.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            location,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    // Title
                                    Text(
                                      place.displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Generative Summary
                                    if (place.generativeSummary.isNotEmpty)
                                      Text(
                                        place.generativeSummary,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    // Disclosure Text
                                    if (place.disclosureText.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        place.disclosureText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],

                                    const SizedBox(height: 8),

                                    // Rating and reviews
                                    if (place.rating != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            ).stars(place.rating!.toString()),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (place.userRatingCount !=
                                              null) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              ).reviews(
                                                _formatRatingCount(
                                                  place.userRatingCount!,
                                                ),
                                              ),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation is now handled by the ScaffoldWithNavBar in router.dart
    );
  }

  // Helper method to format rating count (e.g., 1200 -> 1.2k)
  String _formatRatingCount(int count) {
    if (count >= 1000) {
      final double countInK = count / 1000;
      return '${countInK.toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
