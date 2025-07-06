import 'place_text.dart';

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
