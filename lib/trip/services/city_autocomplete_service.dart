import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/config/config.dart';
import '../models/autocomplete_models.dart';

/// Abstract interface for city autocomplete functionality
/// Follows Interface Segregation Principle - focused interface for city search
abstract class CityAutocompleteService {
  Future<List<PlaceSuggestion>> searchCities(String query);
}

/// Google Places API implementation of city autocomplete service
/// Follows Single Responsibility Principle - only handles city search via Google Places API
class GooglePlacesCityAutocompleteService implements CityAutocompleteService {
  GooglePlacesCityAutocompleteService({required this.apiKey, this.httpClient})
    : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final http.Client? httpClient;
  final http.Client _httpClient;

  static const String _baseUrl =
      'https://places.googleapis.com/v1/places:autocomplete';

  @override
  Future<List<PlaceSuggestion>> searchCities(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _httpClient.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json', 'X-Goog-Api-Key': apiKey},
        body: json.encode({
          'input': query.trim(),
          'includedPrimaryTypes': ['(cities)'],
          'languageCode': 'en-US',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final autocompleteResponse = AutocompleteResponse.fromJson(data);

        return autocompleteResponse.suggestions
            .where(
              (suggestion) => suggestion.placePrediction.displayText.isNotEmpty,
            )
            .take(10)
            .toList();
      } else {
        // Log error but don't throw - fall back to empty list
        print(
          'Google Places API error: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      // Log error but don't throw - fall back to empty list
      print('Error fetching city suggestions: $e');
      return [];
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Provider for Google Places API key
/// Fetches the API key from the configuration
final googlePlacesApiKeyProvider = Provider<String?>((ref) {
  return googlePlacesApiKey.isNotEmpty ? googlePlacesApiKey : null;
});

/// Provider for city autocomplete service
/// Follows Dependency Inversion Principle - depends on abstraction
/// Uses Google Places API service with graceful error handling
final cityAutocompleteServiceProvider = Provider<CityAutocompleteService>((
  ref,
) {
  final apiKey = ref.watch(googlePlacesApiKeyProvider);

  // Always use Google service - it handles empty/invalid API keys gracefully
  return GooglePlacesCityAutocompleteService(apiKey: apiKey ?? '');
});
