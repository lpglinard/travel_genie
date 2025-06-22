import 'package:travel_genie/models/place.dart';

/// A model class representing a response of places.
class PaginatedPlaces {
  /// The list of places in the response.
  final List<Place> places;

  /// The token for fetching the next page of results.
  final String? nextPageToken;

  /// Creates a new [PaginatedPlaces] instance.
  const PaginatedPlaces({required this.places, this.nextPageToken});

  /// Creates a new [PaginatedPlaces] instance with empty places.
  factory PaginatedPlaces.empty() =>
      const PaginatedPlaces(places: [], nextPageToken: null);
}
