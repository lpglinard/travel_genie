import 'package:travel_genie/models/place.dart';

/// A model class representing a paginated response of places.
class PaginatedPlaces {
  /// The list of places in the current page.
  final List<Place> places;
  
  /// The token for the next page of results, if any.
  final String? nextPageToken;
  
  /// Whether there are more results available.
  bool get hasMoreResults => nextPageToken != null && nextPageToken!.isNotEmpty;

  /// Creates a new [PaginatedPlaces] instance.
  const PaginatedPlaces({
    required this.places,
    this.nextPageToken,
  });
  
  /// Creates a new [PaginatedPlaces] instance with empty places and no next page token.
  factory PaginatedPlaces.empty() => const PaginatedPlaces(places: []);
  
  /// Creates a new [PaginatedPlaces] instance with the places from this instance
  /// and the places from [other] appended to the end.
  PaginatedPlaces appendPlaces(List<Place> newPlaces, {String? newNextPageToken}) {
    return PaginatedPlaces(
      places: [...places, ...newPlaces],
      nextPageToken: newNextPageToken,
    );
  }
}