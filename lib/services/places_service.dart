import 'dart:convert';

import 'package:http/http.dart' as http;

class PlacesService {
  PlacesService(this.apiKey);

  final String apiKey;
  final _client = http.Client();

  Future<List<String>> autocomplete(
    String input, {
    String? regionCode,
    String? locationBias,
  }) async {
    if (input.isEmpty) return [];
    final uri = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'suggestions.placePrediction.text.text,suggestions.queryPrediction.text.text',
    };
    final body = {
      'input': input,
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
    final suggestions = data['suggestions'] as List? ?? [];
    final results = suggestions
        .map((e) {
          final prediction =
              e['placePrediction'] ??
              e['queryPrediction'] as Map<String, dynamic>?;
          if (prediction == null) return null;
          final text = prediction['text'] as Map<String, dynamic>?;
          return text?['text'] as String?;
        })
        .whereType<String>()
        .toList();
    return results;
  }
}
