import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../services/recommendation_service.dart';
import './user_providers.dart';

/// Represents the state of search results
class SearchResultsState {
  /// The list of places in the search results
  final List<Place> places;

  /// Any error that occurred during search
  final Object? error;

  /// Whether the search is in a loading state
  final bool isLoading;

  /// Whether more results are being loaded (for pagination)
  final bool isLoadingMore;

  /// Token for fetching the next page of results
  final String? nextPageToken;

  const SearchResultsState({
    this.places = const [],
    this.error,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.nextPageToken,
  });

  /// Creates an empty state with no results
  factory SearchResultsState.empty() => const SearchResultsState();

  /// Creates a loading state
  factory SearchResultsState.loading() =>
      const SearchResultsState(isLoading: true);

  /// Creates a state with the given error
  factory SearchResultsState.error(Object error) =>
      SearchResultsState(error: error);

  /// Creates a copy of this state with the given fields replaced
  SearchResultsState copyWith({
    List<Place>? places,
    Object? error,
    bool? isLoading,
    bool? isLoadingMore,
    String? nextPageToken,
  }) {
    return SearchResultsState(
      places: places ?? this.places,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextPageToken: nextPageToken,
    );
  }
}

/// Notifier that manages search results state
class SearchResultsNotifier extends StateNotifier<SearchResultsState> {
  SearchResultsNotifier(this._service, this._locale)
    : super(SearchResultsState.empty());

  final RecommendationService _service;
  final String? _locale;
  String _lastQuery = '';
  bool _isSearching = false;
  bool _isLoadingMore = false;

  /// Getter for the last search query
  String get lastQuery => _lastQuery;

  /// Performs a new search with the given query
  Future<void> search(String query) async {
    // Prevent concurrent searches
    if (_isSearching) return;

    // Update the last query
    _lastQuery = query;

    if (query.isEmpty) {
      state = SearchResultsState.empty();
      return;
    }

    _isSearching = true;
    state = SearchResultsState.loading();

    try {
      final results = await _service.search(query, languageCode: _locale);
      state = SearchResultsState(
        places: results.places,
        nextPageToken: results.nextPageToken,
      );
    } catch (e) {
      state = SearchResultsState.error(e);
    } finally {
      _isSearching = false;
    }
  }

  /// Loads more search results using the nextPageToken
  Future<void> loadMore() async {
    // Return if there's no nextPageToken or if it's empty or if we're already loading more
    if (state.nextPageToken == null ||
        state.nextPageToken!.isEmpty ||
        _isLoadingMore ||
        _isSearching) {
      return;
    }

    _isLoadingMore = true;
    state = state.copyWith(isLoadingMore: true, nextPageToken: state.nextPageToken);

    try {
      final results = await _service.search(
        _lastQuery,
        languageCode: _locale,
        pageToken: state.nextPageToken,
      );

      // Append new places to existing ones
      final updatedPlaces = [...state.places, ...results.places];

      // If nextPageToken is null or empty, it means there are no more pages to fetch
      // We should update the state with null nextPageToken to prevent further loadMore calls
      state = state.copyWith(
        places: updatedPlaces,
        nextPageToken: results.nextPageToken,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(error: e, isLoadingMore: false);
    } finally {
      _isLoadingMore = false;
    }
  }
}

/// Provider for search results
final searchResultsProvider =
    StateNotifierProvider<SearchResultsNotifier, SearchResultsState>((ref) {
      final service = ref.watch(recommendationServiceProvider);
      final locale = ref.watch(localeProvider);
      return SearchResultsNotifier(service, locale?.languageCode);
    }, name: 'searchResultsProvider');
