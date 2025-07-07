import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/paginated_places.dart';
import '../models/place.dart';
import 'recommendation_service.dart';

class RecommendationServiceImpl implements RecommendationService {
  RecommendationServiceImpl({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  @override
  Future<PaginatedPlaces> search(
    String name, {
    String? languageCode,
    String? pageToken,
  }) async {
    final queryParams = <String, String>{
      'query': "atrações turísticas em $name",
      'languageCode': languageCode ?? 'en',
    };

    if (pageToken != null && pageToken.isNotEmpty) {
      queryParams['pageToken'] = pageToken;
    }

    final uri = Uri.parse(
      'https://sophisticated-chimera.odsy.to/places-recommendations',
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

  PaginatedPlaces _parsePlacesResponse(String responseBody) {
    final jsonData = json.decode(responseBody);
    List<dynamic> data;

    if (jsonData is Map<String, dynamic>) {
      if (jsonData['places'] is List) {
        data = jsonData['places'];
      } else if (jsonData['results'] is List) {
        data = jsonData['results'];
      } else {
        data = jsonData.entries
                .firstWhere((entry) => entry.value is List, orElse: () => MapEntry('', []))
                .value ?? [];
      }
    } else if (jsonData is List<dynamic>) {
      data = jsonData;
    } else {
      throw Exception('Unexpected response format: ${jsonData.runtimeType}');
    }

    final places = data.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
    String? nextPageToken = (jsonData is Map<String, dynamic>) ? jsonData['nextPageToken'] : null;
    if (nextPageToken == null || nextPageToken.isEmpty || places.length >= 60) {
      nextPageToken = null;
    }

    return PaginatedPlaces(places: places, nextPageToken: nextPageToken);
  }
}
