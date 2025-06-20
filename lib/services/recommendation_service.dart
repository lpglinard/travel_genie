import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/paginated_places.dart';
import '../models/place.dart';

class RecommendationService {
  RecommendationService({http.Client? client})
    : _client = client ?? http.Client();
  final http.Client _client;

  Future<PaginatedPlaces> search(String name, {String? languageCode, String? nextPageToken}) async {
    final encodedName = Uri.encodeComponent(name);
    final queryParams = <String, String>{
      'languageCode': languageCode ?? 'en',
      // Always include languageCode, default to 'en' if not provided
    };

    // Add nextPageToken to query parameters if provided
    if (nextPageToken != null && nextPageToken.isNotEmpty) {
      queryParams['pageToken'] = nextPageToken;
    }

    final uri = Uri.parse(
      'https://recommendations-1052236350369.europe-west1.run.app/places/$encodedName',
    ).replace(queryParameters: queryParams);
    
    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch recommendations: Status ${response.statusCode}',
        );
      }

      try {
        final jsonData = json.decode(response.body);

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
              throw Exception(
                'Could not find a list of places in the response',
              );
            }
          }
        } else if (jsonData is List<dynamic>) {
          // If the response is already a List, use it directly
          data = jsonData;
        } else {
          throw Exception(
            'Unexpected response format: ${jsonData.runtimeType}',
          );
        }

        // Extract places from the data
        final places = data
            .map((e) => Place.fromJson(e as Map<String, dynamic>))
            .toList();

        // Extract next_page_token if available
        String? nextPageToken;
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('next_page_token')) {
          nextPageToken = jsonData['next_page_token'] as String?;
        }

        return PaginatedPlaces(
          places: places,
          nextPageToken: nextPageToken,
        );
      } catch (parseError, st) {
        throw Exception('Failed to parse recommendations: $parseError');
      }
    } catch (e, st) {
      rethrow;
    }
  }
}