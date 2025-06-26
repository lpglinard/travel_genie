import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:travel_genie/models/paginated_places.dart';
import 'package:travel_genie/models/place.dart';

class RecommendationService {
  RecommendationService({http.Client? client})
    : _client = client ?? http.Client();
  final http.Client _client;

  Future<PaginatedPlaces> search(
    String name, {
    String? languageCode,
    String? pageToken,
  }) async {
    final queryParams = <String, String>{
      'query': "atrações turísticas em " + name,
      'languageCode': languageCode ?? 'en',
      // Always include languageCode, default to 'en' if not provided
    };

    // Add pageToken if provided
    if (pageToken != null && pageToken.isNotEmpty) {
      queryParams['pageToken'] = pageToken;
    }

    final uri = Uri.parse(
      'https://sophisticated-chimera-1052236350369.us-central1.run.app/places-recommendations',
    ).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch recommendations: Status ${response.statusCode}',
        );
      }

      return _parsePlacesResponse(response.body);
    } catch (e) {
      rethrow;
    }
  }

  /// Parses a JSON response string into a PaginatedPlaces object
  PaginatedPlaces _parsePlacesResponse(String responseBody) {
    try {
      final jsonData = json.decode(responseBody);

      List<dynamic> data;

      if (jsonData is Map<String, dynamic>) {
        // If the response is a Map, try to find a key that might contain the list of places
        if (jsonData.containsKey('places')) {
          final places = jsonData['places'];

          if (places is List) {
            data = places;
          } else {
            throw Exception(
              'The "places" field is not a List: ${places.runtimeType}',
            );
          }
        } else if (jsonData.containsKey('results')) {
          final results = jsonData['results'];

          if (results is List) {
            data = results;
          } else {
            throw Exception(
              'The "results" field is not a List: ${results.runtimeType}',
            );
          }
        } else {
          // If we can't find a known key, look for the first List value
          final listEntry = jsonData.entries.firstWhere(
            (entry) => entry.value is List,
            orElse: () => MapEntry('', []),
          );

          if (listEntry.value is List) {
            data = listEntry.value as List<dynamic>;
          } else {
            throw Exception('Could not find a list of places in the response');
          }
        }
      } else if (jsonData is List<dynamic>) {
        // If the response is already a List, use it directly
        data = jsonData;
      } else {
        throw Exception('Unexpected response format: ${jsonData.runtimeType}');
      }

      // Extract places from the data
      final places = data
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList();

      // Extract nextPageToken if available
      String? nextPageToken;
      if (jsonData is Map<String, dynamic>) {
        if (jsonData.containsKey('nextPageToken')) {
          nextPageToken = jsonData['nextPageToken'] as String?;

          // If nextPageToken is null or empty, treat it as null (no more pages)
          if (nextPageToken == null || nextPageToken.isEmpty) {
            nextPageToken = null;
          }

          // According to the issue description, the API doesn't return a nextPageToken after 60 results
          // If we already have 60 or more places, set nextPageToken to null to prevent further loadMore calls
          if (places.length >= 60) {
            nextPageToken = null;
          }
        }
      }

      return PaginatedPlaces(places: places, nextPageToken: nextPageToken);
    } catch (parseError) {
      throw Exception('Failed to parse places response: $parseError');
    }
  }
}
