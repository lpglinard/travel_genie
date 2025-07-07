import 'package:travel_genie/features/trip/models/autocomplete_response.dart';

void main() {
  // Simplified sample data from the issue description
  final simplifiedJson = {
    "suggestions": [
      {
        "placePrediction": {
          "placeId": "ChIJEcHIDqKw2YgRZU-t3XHylv8",
          "text": {"text": "Miami, FL, USA"},
          "structuredFormat": {
            "mainText": {"text": "Miami"},
          },
        },
      },
      {
        "placePrediction": {
          "placeId": "ChIJud3-Kxem2YgR62OUJUEXvjc",
          "text": {"text": "Miami Beach, FL, USA"},
          "structuredFormat": {
            "mainText": {"text": "Miami Beach"},
          },
        },
      },
      {
        "placePrediction": {
          "placeId": "ChIJ7xGQyOVAoRIR_mLOMnbfntc",
          "text": {"text": "Miami Platja, Spain"},
          "structuredFormat": {
            "mainText": {"text": "Miami Platja"},
          },
        },
      },
      {
        "placePrediction": {
          "placeId": "ChIJZy-MgLuv2YgR1Wvi5YjYme0",
          "text": {"text": "Miami Gardens, FL, USA"},
          "structuredFormat": {
            "mainText": {"text": "Miami Gardens"},
          },
        },
      },
      {
        "placePrediction": {
          "placeId": "ChIJZ0ta15kXyIcRcVKXoEO_YYQ",
          "text": {"text": "Miami, OK, USA"},
          "structuredFormat": {
            "mainText": {"text": "Miami"},
          },
        },
      },
    ],
  };

  try {
    // Test parsing the simplified sample data
    final response = AutocompleteResponse.fromJson(simplifiedJson);
    print('✓ Successfully parsed AutocompleteResponse');

    print('Number of suggestions: ${response.suggestions.length}');

    for (int i = 0; i < response.suggestions.length; i++) {
      final suggestion = response.suggestions[i];
      final prediction = suggestion.placePrediction;

      print('\nSuggestion ${i + 1}:');
      print('  PlaceId: ${prediction.placeId}');
      print('  Text: ${prediction.text.text}');
      print('  Main text: ${prediction.mainText}');
      print(
        '  Secondary text: "${prediction.secondaryText}" (should be empty)',
      );
      print('  Display text: ${prediction.displayText}');
      print('  Formatted text: ${prediction.formattedText}');
    }

    // Test toJson conversion
    final backToJson = response.toJson();
    print('\n✓ Successfully converted back to JSON');

    // Verify specific values from the sample
    final firstPrediction = response.suggestions[0].placePrediction;
    assert(firstPrediction.placeId == "ChIJEcHIDqKw2YgRZU-t3XHylv8");
    assert(firstPrediction.text.text == "Miami, FL, USA");
    assert(firstPrediction.mainText == "Miami");
    assert(
      firstPrediction.secondaryText == "",
    ); // Should be empty since no secondaryText in sample
    print('✓ All assertions passed');

    print(
      '\n🎉 Test completed successfully! The simplified model works correctly.',
    );
  } catch (e, stackTrace) {
    print('✗ Error parsing simplified sample data: $e');
    print('Stack trace: $stackTrace');
  }
}
