import '../models/place.dart';

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