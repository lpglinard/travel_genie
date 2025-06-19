import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/user_providers.dart';

import '../models/place.dart';
import '../services/recommendation_service.dart';

class SearchResultsNotifier
    extends StateNotifier<AsyncValue<List<Place>>> {
  SearchResultsNotifier(this._service)
      : super(const AsyncValue.data(<Place>[]));

  final RecommendationService _service;

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data(<Place>[]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final results = await _service.search(query);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final searchResultsProvider =
    StateNotifierProvider<SearchResultsNotifier, AsyncValue<List<Place>>>(
        (ref) {
  final service = ref.watch(recommendationServiceProvider);
  return SearchResultsNotifier(service);
});
