import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  PlacesService(this.apiKey);
  final String apiKey;
  final _client = http.Client();

  Future<List<String>> autocomplete(
    String input, {
    int maxResults = 5,
    String? regionCode,
    String? locationBias,
  }) async {
    if (input.isEmpty) return [];
    final uri = Uri.parse('https://places.googleapis.com/v1/places:autocomplete');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.displayName',
    };
    final body = {
      'input': input,
      'maxResultCount': maxResults,
      if (regionCode != null) 'regionCode': regionCode,
      if (locationBias != null) 'locationBias': locationBias,
    };

    final response = await _client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Autocomplete failed: ${response.body}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final predictions = data['places'] as List? ?? data['predictions'] as List? ?? [];
    return predictions
        .map((e) => e['displayName']?['text'] as String?)
        .whereType<String>()
        .toList();
  }
}
