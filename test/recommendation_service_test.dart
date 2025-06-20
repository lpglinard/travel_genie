import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:travel_genie/services/recommendation_service.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/models/paginated_places.dart';

// Simple mock of http.Client
class MockHttpClient implements http.Client {
  final Map<String, http.Response> responses = {};

  void addResponse(Uri uri, http.Response response) {
    responses[uri.toString()] = response;
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return responses[url.toString()] ?? http.Response('Not found', 404);
  }

  @override
  void close() {}

  // Implement other methods as needed
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnsupportedError('Unimplemented method: ${invocation.memberName}');
  }
}

void main() {
  late RecommendationService recommendationService;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    recommendationService = RecommendationService(client: mockClient);
  });

  test('search returns paginated places when response is successful without languageCode', () async {
    // Create a simplified JSON response with only the essential fields
    final jsonString = '''
    {
      "city": "fortaleza",
      "places": [
        {
          "place_id": "123",
          "display_name": "Martyrs Square",
          "formatted_address": "Praca dos Martires - Centro, Fortaleza - CE, 60030-000, Brazil",
          "google_maps_uri": "https://maps.google.com/?cid=12976531288368862883",
          "location": {"lat": -3.7228790999999997, "lng": -38.5264022},
          "generative_summary": {
            "overview": {
              "text": "A historic square in the heart of Fortaleza."
            },
            "disclosure_text": {
              "text": "Information may not be up to date."
            }
          }
        }
      ]
    }
    ''';

    // Set up the mock client to return the simplified JSON content
    final uri = Uri.parse('https://recommendations-1052236350369.europe-west1.run.app/places/fortaleza')
        .replace(queryParameters: {'languageCode': 'en'});
    mockClient.addResponse(uri, http.Response(jsonString, 200, headers: {'content-type': 'application/json; charset=utf-8'}));

    // Call the method under test
    final result = await recommendationService.search('fortaleza');

    // Verify the result
    expect(result, isA<PaginatedPlaces>());
    expect(result.places, isNotEmpty);
    expect(result.places.first.displayName, 'Martyrs Square');
  });

  test('search returns paginated places when response is successful with languageCode', () async {
    // Create a simplified JSON response with only the essential fields
    final jsonString = '''
    {
      "city": "fortaleza",
      "places": [
        {
          "place_id": "123",
          "display_name": "Martyrs Square",
          "formatted_address": "Praca dos Martires - Centro, Fortaleza - CE, 60030-000, Brazil",
          "google_maps_uri": "https://maps.google.com/?cid=12976531288368862883",
          "location": {"lat": -3.7228790999999997, "lng": -38.5264022},
          "generative_summary": {
            "overview": {
              "text": "A historic square in the heart of Fortaleza."
            },
            "disclosure_text": {
              "text": "Information may not be up to date."
            }
          }
        }
      ]
    }
    ''';

    // Set up the mock client to return the simplified JSON content
    final uri = Uri.parse('https://recommendations-1052236350369.europe-west1.run.app/places/fortaleza')
        .replace(queryParameters: {'languageCode': 'pt'});
    mockClient.addResponse(uri, http.Response(jsonString, 200, headers: {'content-type': 'application/json; charset=utf-8'}));

    // Call the method under test
    final result = await recommendationService.search('fortaleza', languageCode: 'pt');

    // Verify the result
    expect(result, isA<PaginatedPlaces>());
    expect(result.places, isNotEmpty);
    expect(result.places.first.displayName, 'Martyrs Square');
  });
}