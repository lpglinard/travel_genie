import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/paginated_places.dart';
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

  const SearchResultsState({
    this.places = const [],
    this.error,
    this.isLoading = false,
  });

  /// Creates an empty state with no results
  factory SearchResultsState.empty() => const SearchResultsState();

  /// Creates a loading state
  factory SearchResultsState.loading() => const SearchResultsState(isLoading: true);

  /// Creates a state with the given error
  factory SearchResultsState.error(Object error) => 
      SearchResultsState(error: error);
}

/// Notifier that manages search results state
class SearchResultsNotifier extends StateNotifier<SearchResultsState> {
  SearchResultsNotifier(this._service, this._locale)
    : super(SearchResultsState.empty());

  final RecommendationService _service;
  final String? _locale;
  String _lastQuery = '';
  bool _isSearching = false;

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
      state = SearchResultsState(places: results.places);
    } catch (e) {
      state = SearchResultsState.error(e);
    } finally {
      _isSearching = false;
    }
  }
}

/// Provider for search results
final searchResultsProvider = StateNotifierProvider<SearchResultsNotifier, SearchResultsState>(
  (ref) {
    final service = ref.watch(recommendationServiceProvider);
    final locale = ref.watch(localeProvider);
    return SearchResultsNotifier(service, locale?.languageCode);
  },
  name: 'searchResultsProvider',
);