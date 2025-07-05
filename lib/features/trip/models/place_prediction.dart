import 'place_text.dart';
import 'structured_format.dart';

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