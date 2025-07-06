import 'place_prediction.dart';

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
