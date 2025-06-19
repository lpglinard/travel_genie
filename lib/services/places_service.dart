import 'dart:convert';
import 'dart:developer';
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
    log('Autocomplete called with input: "' + input + '"');
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

    log('Sending POST to ' + uri.toString() + ' with body: ' + body.toString());
    final response = await _client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    log('Received response: status ' + response.statusCode.toString());

    if (response.statusCode != 200) {
      log('Autocomplete failed: ' + response.body, level: 1000);
      throw Exception('Autocomplete failed: ${response.body}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final predictions = data['places'] as List? ?? data['predictions'] as List? ?? [];
    final results = predictions
        .map((e) => e['displayName']?['text'] as String?)
        .whereType<String>()
        .toList();
    log('Parsed predictions: ' + results.toString());
    return results;
  }
}
