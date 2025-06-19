import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:travel_genie/services/recommendation_service.dart';
import 'package:travel_genie/models/place.dart';

// Simple mock of http.Client
class MockHttpClient implements http.Client {
  final Map<Uri, http.Response> responses = {};

  void addResponse(Uri uri, http.Response response) {
    responses[uri] = response;
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return responses[url] ?? http.Response('Not found', 404);
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

  test('search returns list of places when response is successful', () async {
    // Load the fortaleza.json file
    final file = File('fortaleza.json');
    final jsonString = await file.readAsString();

    // Set up the mock client to return the fortaleza.json content
    final uri = Uri.parse('https://recommendations-1052236350369.europe-west1.run.app/places/fortaleza');
    mockClient.addResponse(uri, http.Response(jsonString, 200));

    // Call the method under test
    final places = await recommendationService.search('fortaleza');

    // Verify the result
    expect(places, isA<List<Place>>());
    expect(places.isNotEmpty, true);
    expect(places.first.displayName, 'Martyrs Square');
  });
}
