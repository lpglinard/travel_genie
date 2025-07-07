abstract class PlacesService {
  Future<List<String>> autocomplete(
    String input, {
    String? regionCode,
    Map<String, dynamic>? locationBias,
  });
}
