import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DaySummaryService {
  DaySummaryService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  /// Fetches a summary for a specific day in a trip
  ///
  /// Parameters:
  /// - userId: The ID of the user
  /// - tripId: The ID of the trip
  /// - dayId: The ID of the day to summarize
  /// - languageCode: The language code for the summary (e.g., 'en', 'pt')
  Future<Map<String, dynamic>> getDaySummary({
    required String tripId,
    required String dayId,
    required String languageCode,
  }) async {
    final uri = Uri.parse(
      'https://sophisticated-chimera.odsy.to/itinerary-summary/summary',
    );

    final requestBody = {
      'tripId': tripId,
      'dayId': dayId,
      'languageCode': languageCode,
    };

    debugPrint(
      'DaySummaryService: Fetching day summary for tripId=$tripId, dayId=$dayId, languageCode=$languageCode',
    );
    debugPrint('DaySummaryService: Request URL: $uri');
    debugPrint('DaySummaryService: Request body: ${json.encode(requestBody)}');

    try {
      final stopwatch = Stopwatch()..start();

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'travel_genie/app',
        },
        body: json.encode(requestBody),
      );

      stopwatch.stop();
      debugPrint(
        'DaySummaryService: Request completed in ${stopwatch.elapsedMilliseconds}ms',
      );
      debugPrint(
        'DaySummaryService: Response status code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        debugPrint('DaySummaryService: Successfully fetched day summary');
        // Log a truncated version of the response body to avoid flooding the logs
        final truncatedBody = response.body.length > 500
            ? '${response.body.substring(0, 500)}...(truncated)'
            : response.body;
        debugPrint('DaySummaryService: Response body: $truncatedBody');

        return _parseSummaryResponse(response.body);
      } else {
        debugPrint(
          'DaySummaryService: Failed to fetch day summary: Status ${response.statusCode}',
        );
        debugPrint('DaySummaryService: Error response: ${response.body}');

        throw Exception(
          'Failed to fetch day summary: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint(
        'DaySummaryService: Exception occurred while fetching day summary: $e',
      );
      rethrow;
    }
  }

  /// Parses a JSON response string into a Map
  Map<String, dynamic> _parseSummaryResponse(String responseBody) {
    debugPrint('DaySummaryService: Parsing summary response');

    try {
      final stopwatch = Stopwatch()..start();
      final jsonData = json.decode(responseBody);
      stopwatch.stop();

      debugPrint(
        'DaySummaryService: JSON parsing completed in ${stopwatch.elapsedMilliseconds}ms',
      );

      if (jsonData is Map<String, dynamic>) {
        debugPrint(
          'DaySummaryService: Successfully parsed response as Map<String, dynamic>',
        );
        debugPrint(
          'DaySummaryService: Response contains ${jsonData.length} keys: ${jsonData.keys.join(', ')}',
        );
        return jsonData;
      } else {
        debugPrint(
          'DaySummaryService: Unexpected response format: ${jsonData.runtimeType}',
        );
        throw Exception('Unexpected response format: ${jsonData.runtimeType}');
      }
    } catch (parseError) {
      debugPrint(
        'DaySummaryService: Failed to parse summary response: $parseError',
      );
      throw Exception('Failed to parse summary response: $parseError');
    }
  }
}
