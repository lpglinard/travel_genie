import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'app_check_client.dart';

import '../models/place.dart';

class RecommendationService {
  RecommendationService();
  final _client = AppCheckClient();

  Future<List<Place>> search(String name) async {
    final encodedName = Uri.encodeComponent(name);
    final uri = Uri.parse('https://recommendations.odsy.to/places/$encodedName');
    log('GET \$uri');
    final response = await _client.get(uri);
    log('RecommendationService response: \${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch recommendations');
    }
    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((e) => Place.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
