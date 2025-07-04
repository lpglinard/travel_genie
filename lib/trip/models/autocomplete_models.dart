/// Model classes for Google Places API autocomplete responses
/// Follows Single Responsibility Principle - each class handles one specific data structure

class AutocompleteResponse {
  const AutocompleteResponse({required this.suggestions});

  final List<PlaceSuggestion> suggestions;

  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) {
    final suggestionsJson = json['suggestions'] as List<dynamic>? ?? [];
    final suggestions = suggestionsJson
        .map(
          (suggestion) =>
              PlaceSuggestion.fromJson(suggestion as Map<String, dynamic>),
        )
        .toList();

    return AutocompleteResponse(suggestions: suggestions);
  }

  Map<String, dynamic> toJson() {
    return {'suggestions': suggestions.map((s) => s.toJson()).toList()};
  }
}

class PlaceSuggestion {
  const PlaceSuggestion({required this.placePrediction});

  final PlacePrediction placePrediction;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final predictionJson =
        json['placePrediction'] as Map<String, dynamic>? ?? {};
    return PlaceSuggestion(
      placePrediction: PlacePrediction.fromJson(predictionJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {'placePrediction': placePrediction.toJson()};
  }
}

class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.text,
    required this.structuredFormat,
  });

  final String placeId;
  final PlaceText text;
  final StructuredFormat structuredFormat;

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final textJson = json['text'] as Map<String, dynamic>? ?? {};
    final structuredFormatJson =
        json['structuredFormat'] as Map<String, dynamic>? ?? {};

    return PlacePrediction(
      placeId: json['placeId'] as String? ?? '',
      text: PlaceText.fromJson(textJson),
      structuredFormat: StructuredFormat.fromJson(structuredFormatJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'text': text.toJson(),
      'structuredFormat': structuredFormat.toJson(),
    };
  }

  /// Returns the display text for this place prediction
  String get displayText => text.text;

  /// Returns the main text (city name) for this place prediction
  String get mainText => structuredFormat.mainText.text;

  /// Returns the secondary text (state/country) for this place prediction
  String get secondaryText => structuredFormat.secondaryText?.text ?? '';

  /// Returns the full formatted text for display
  String get formattedText {
    if (secondaryText.isNotEmpty) {
      return '$mainText, $secondaryText';
    }
    return mainText;
  }
}

class PlaceText {
  const PlaceText({required this.text});

  final String text;

  factory PlaceText.fromJson(Map<String, dynamic> json) {
    return PlaceText(text: json['text'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}

class StructuredFormat {
  const StructuredFormat({required this.mainText, this.secondaryText});

  final PlaceText mainText;
  final PlaceText? secondaryText;

  factory StructuredFormat.fromJson(Map<String, dynamic> json) {
    final mainTextJson = json['mainText'] as Map<String, dynamic>? ?? {};
    final secondaryTextJson = json['secondaryText'] as Map<String, dynamic>?;

    return StructuredFormat(
      mainText: PlaceText.fromJson(mainTextJson),
      secondaryText: secondaryTextJson != null
          ? PlaceText.fromJson(secondaryTextJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainText': mainText.toJson(),
      if (secondaryText != null) 'secondaryText': secondaryText!.toJson(),
    };
  }
}
