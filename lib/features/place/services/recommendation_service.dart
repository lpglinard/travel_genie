import 'package:travel_genie/features/place/models/paginated_places.dart';

abstract class RecommendationService {
  Future<PaginatedPlaces> search(
    String name, {
    String? languageCode,
    String? pageToken,
  });
}
