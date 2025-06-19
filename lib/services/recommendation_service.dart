import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../models/place.dart';

class RecommendationService {
  RecommendationService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<Place>> search(String name) async {
    final encodedName = Uri.encodeComponent(name);
    final uri = Uri.parse('https://recommendations-1052236350369.europe-west1.run.app/places/$encodedName');
    log('RecommendationService - GET $uri');
    try {
      final response = await _client.get(uri);
      log('RecommendationService response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        log('RecommendationService error: Non-200 status code. Response body: ${response.body}');
        throw Exception('Failed to fetch recommendations: Status ${response.statusCode}');
      }

      log('RecommendationService response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');

      try {
        final jsonData = json.decode(response.body);
        log('RecommendationService jsonData type: ${jsonData.runtimeType}');

        List<dynamic> data;

        if (jsonData is Map<String, dynamic>) {
          // Log the keys to help debug
          log('RecommendationService response keys: ${jsonData.keys.join(', ')}');

          // If the response is a Map, try to find a key that might contain the list of places
          if (jsonData.containsKey('places')) {
            final places = jsonData['places'];
            log('RecommendationService places type: ${places.runtimeType}');

            if (places is List) {
              data = places;
            } else {
              throw Exception('The "places" field is not a List: ${places.runtimeType}');
            }
          } else if (jsonData.containsKey('results')) {
            final results = jsonData['results'];
            log('RecommendationService results type: ${results.runtimeType}');

            if (results is List) {
              data = results;
            } else {
              throw Exception('The "results" field is not a List: ${results.runtimeType}');
            }
          } else {
            // If we can't find a known key, look for the first List value
            final listEntry = jsonData.entries
                .firstWhere((entry) => entry.value is List, 
                    orElse: () => MapEntry('', []));

            if (listEntry.value is List) {
              data = listEntry.value as List<dynamic>;
              log('RecommendationService found list in key: ${listEntry.key}');
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

        log('RecommendationService parsed ${data.length} places from response');
        return data
            .map((e) => Place.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (parseError, st) {
        log('RecommendationService JSON parsing error: $parseError', error: parseError, stackTrace: st);
        throw Exception('Failed to parse recommendations: $parseError');
      }
    } catch (e, st) {
      log('RecommendationService request error: $e', error: e, stackTrace: st);
      rethrow;
    }
  }
}
