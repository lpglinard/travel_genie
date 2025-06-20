import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/models/paginated_places.dart';
import 'package:travel_genie/user_providers.dart';

import '../models/place.dart';
import '../services/recommendation_service.dart';

/// Represents the state of search results, including pagination status
class SearchResultsState {
  /// The list of places in the current page
  final List<Place> places;

  /// The token for the next page of results, if any
  final String? nextPageToken;

  /// Whether more results are being loaded
  final bool isLoadingMore;

  /// Any error that occurred during search
  final Object? error;

  /// Stack trace for the error
  final StackTrace? stackTrace;

  /// Whether the search is in a loading state
  final bool isLoading;

  const SearchResultsState({
    this.places = const [],
    this.nextPageToken,
    this.isLoadingMore = false,
    this.error,
    this.stackTrace,
    this.isLoading = false,
  });

  /// Creates an empty state with no results
  factory SearchResultsState.empty() => const SearchResultsState();

  /// Creates a loading state
  factory SearchResultsState.loading() => const SearchResultsState(isLoading: true);

  /// Creates a state with the given error
  factory SearchResultsState.error(Object error, StackTrace stackTrace) => 
      SearchResultsState(error: error, stackTrace: stackTrace);

  /// Returns a new state with the given values
  SearchResultsState copyWith({
    List<Place>? places,
    String? nextPageToken,
    bool? isLoadingMore,
    Object? error,
    StackTrace? stackTrace,
    bool? isLoading,
  }) {
    return SearchResultsState(
      places: places ?? this.places,
      nextPageToken: nextPageToken ?? this.nextPageToken,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Returns true if there are more results available
  bool get hasMoreResults => nextPageToken != null && nextPageToken!.isNotEmpty;
}

class SearchResultsNotifier extends StateNotifier<SearchResultsState> {
  SearchResultsNotifier(this._service, this._locale)
    : super(SearchResultsState.empty());

  final RecommendationService _service;
  final String? _locale;
  String _lastQuery = '';
  bool _isSearching = false;

  // Getter for the last search query
  String get lastQuery => _lastQuery;

  /// Performs a new search with the given query
  Future<void> search(String query) async {
    log('SearchResultsNotifier.search called with query: $query');

    // Prevent concurrent searches
    if (_isSearching) {
      log('SearchResultsNotifier.search - Already searching, ignoring request');
      return;
    }

    // Update the last query
    _lastQuery = query;

    if (query.isEmpty) {
      log('Query is empty, clearing search results');
      state = SearchResultsState.empty();
      return;
    }

    _isSearching = true;

    // Set loading state
    state = SearchResultsState.loading();

    try {
      log(
        'Calling recommendation service with query: $query' +
            (_locale != null ? ', languageCode: $_locale' : ''),
      );
      final paginatedResults = await _service.search(query, languageCode: _locale);
      log('Search returned ${paginatedResults.places.length} results' + 
          (paginatedResults.nextPageToken != null ? ' with next page token' : ''));

      state = SearchResultsState(
        places: paginatedResults.places,
        nextPageToken: paginatedResults.nextPageToken,
      );
    } catch (e, st) {
      log('Search error: $e', error: e, stackTrace: st);
      state = SearchResultsState.error(e, st);
    } finally {
      _isSearching = false;
    }
  }

  /// Loads more results using the next page token
  Future<void> loadMore() async {
    // Don't load more if already loading or if there are no more results
    if (state.isLoadingMore || !state.hasMoreResults) {
      log('SearchResultsNotifier.loadMore - Already loading or no more results, ignoring request');
      return;
    }

    // Set loading more state
    state = state.copyWith(isLoadingMore: true);

    try {
      log('Loading more results for query: $_lastQuery with token: ${state.nextPageToken}');

      final paginatedResults = await _service.search(
        _lastQuery, 
        languageCode: _locale,
        nextPageToken: state.nextPageToken,
      );

      log('Loaded ${paginatedResults.places.length} more results' +
          (paginatedResults.nextPageToken != null ? ' with next page token' : ''));

      // Combine the new results with the existing ones
      final List<Place> combinedPlaces = [
        ...state.places,
        ...paginatedResults.places,
      ];

      state = state.copyWith(
        places: combinedPlaces,
        nextPageToken: paginatedResults.nextPageToken,
        isLoadingMore: false,
      );
    } catch (e, st) {
      log('Load more error: $e', error: e, stackTrace: st);
      state = state.copyWith(
        error: e,
        stackTrace: st,
        isLoadingMore: false,
      );
    }
  }
}

final searchResultsProvider =
    StateNotifierProvider<SearchResultsNotifier, SearchResultsState>(
      (ref) {
        final service = ref.watch(recommendationServiceProvider);
        final locale = ref.watch(localeProvider);
        return SearchResultsNotifier(service, locale?.languageCode);
      },
      // Keep the provider alive even when no widgets are listening to it
      name: 'searchResultsProvider',
    );
