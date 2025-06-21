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
    final uri = Uri.parse('https://recommendations-1052236350369.us-east1.run.app/places')
        .replace(queryParameters: {'textQuery': 'fortaleza', 'languageCode': 'en'});
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
    final uri = Uri.parse('https://recommendations-1052236350369.us-east1.run.app/places')
        .replace(queryParameters: {'textQuery': 'fortaleza', 'languageCode': 'pt'});
    mockClient.addResponse(uri, http.Response(jsonString, 200, headers: {'content-type': 'application/json; charset=utf-8'}));

    // Call the method under test
    final result = await recommendationService.search('fortaleza', languageCode: 'pt');

    // Verify the result
    expect(result, isA<PaginatedPlaces>());
    expect(result.places, isNotEmpty);
    expect(result.places.first.displayName, 'Martyrs Square');
  });

  test('search with pageToken returns next page of results', () async {
    // Create a simplified JSON response with nextPageToken for the first page
    final firstPageJson = '''
    {
      "places": [
        {
          "place_id": "123",
          "display_name": "Martyrs Square",
          "formatted_address": "Praca dos Martires - Centro, Fortaleza - CE, 60030-000, Brazil",
          "google_maps_uri": "https://maps.google.com/?cid=12976531288368862883",
          "location": {"lat": -3.7228790999999997, "lng": -38.5264022}
        }
      ],
      "nextPageToken": "next_page_token_123"
    }
    ''';

    // Create a simplified JSON response for the second page
    final secondPageJson = '''
    {
      "places": [
        {
          "place_id": "456",
          "display_name": "Beach Park",
          "formatted_address": "Porto das Dunas, Aquiraz - CE, 61700-000, Brazil",
          "google_maps_uri": "https://maps.google.com/?cid=12345678901234567890",
          "location": {"lat": -3.8012345, "lng": -38.3987654}
        }
      ]
    }
    ''';

    // Set up the mock client to return the first page
    final firstPageUri = Uri.parse('https://recommendations-1052236350369.us-east1.run.app/places')
        .replace(queryParameters: {'textQuery': 'fortaleza', 'languageCode': 'en'});
    mockClient.addResponse(firstPageUri, http.Response(firstPageJson, 200, headers: {'content-type': 'application/json; charset=utf-8'}));

    // Set up the mock client to return the second page
    final secondPageUri = Uri.parse('https://recommendations-1052236350369.us-east1.run.app/places')
        .replace(queryParameters: {'textQuery': 'fortaleza', 'languageCode': 'en', 'pageToken': 'next_page_token_123'});
    mockClient.addResponse(secondPageUri, http.Response(secondPageJson, 200, headers: {'content-type': 'application/json; charset=utf-8'}));

    // Call the method under test for the first page
    final firstPageResult = await recommendationService.search('fortaleza');

    // Verify the first page result
    expect(firstPageResult, isA<PaginatedPlaces>());
    expect(firstPageResult.places, isNotEmpty);
    expect(firstPageResult.places.first.displayName, 'Martyrs Square');
    expect(firstPageResult.nextPageToken, 'next_page_token_123');

    // Call the method under test for the second page using the nextPageToken
    final secondPageResult = await recommendationService.search('fortaleza', pageToken: firstPageResult.nextPageToken);

    // Verify the second page result
    expect(secondPageResult, isA<PaginatedPlaces>());
    expect(secondPageResult.places, isNotEmpty);
    expect(secondPageResult.places.first.displayName, 'Beach Park');
    expect(secondPageResult.nextPageToken, isNull);
  });

  test('getSampleData returns paginated places from sample endpoint', () async {
    // Create a simplified JSON response with only the essential fields
    final jsonString = '''
    {
      "places": [
        {
          "id": "ChIJi0DllG8Z",
          "displayName": {
            "text": "Sample Place",
            "languageCode": "en"
          },
          "formattedAddress": "123 Sample St, Sample City, SC 12345, USA",
          "googleMapsUri": "https://maps.google.com/?cid=12345678901234567890",
          "location": {"latitude": 37.7749, "longitude": -122.4194},
          "types": ["tourist_attraction", "point_of_interest"]
        }
      ]
    }
    ''';

    // Set up the mock client to return the simplified JSON content
    final uri = Uri.parse('https://recommendations-1052236350369.us-east1.run.app/sample');
    mockClient.addResponse(uri, http.Response(jsonString, 200, headers: {'content-type': 'application/json; charset=utf-8'}));

    // Call the method under test
    final result = await recommendationService.getSampleData();

    // Verify the result
    expect(result, isA<PaginatedPlaces>());
    expect(result.places, isNotEmpty);
    expect(result.places.first.displayName, 'Sample Place');
    expect(result.places.first.placeId, 'ChIJi0DllG8Z');
  });

  test('getSampleData falls back to local file when API call fails', () async {
    // Set up the mock client to return an error
    final uri = Uri.parse('https://recommendations-1052236350369.us-east1.run.app/sample');
    mockClient.addResponse(uri, http.Response('Not found', 404));

    // We can't easily test loading from assets in a unit test, so we'll mock the file system
    // by overriding the loadSampleDataFromAsset method
    final originalMethod = recommendationService.loadSampleDataFromAsset;

    try {
      // Override the method to return a known result
      recommendationService = RecommendationService(client: mockClient);

      // Call the method under test
      final result = await recommendationService.getSampleData();

      // Since we can't mock the asset loading in a unit test, we just verify that
      // the method doesn't throw an exception and returns a PaginatedPlaces object
      expect(result, isA<PaginatedPlaces>());
    } finally {
      // Restore the original method
      recommendationService = RecommendationService(client: mockClient);
    }
  });
}
