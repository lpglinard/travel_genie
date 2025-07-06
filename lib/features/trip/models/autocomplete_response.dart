/// Model classes for Google Places API autocomplete responses
/// Follows Single Responsibility Principle - each class handles one specific data structure

import 'place_suggestion.dart';

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
