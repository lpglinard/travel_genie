import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/user_providers.dart';

import '../models/place.dart';
import '../services/recommendation_service.dart';

class SearchResultsNotifier extends StateNotifier<AsyncValue<List<Place>>> {
  SearchResultsNotifier(this._service, this._locale)
    : super(const AsyncValue.data(<Place>[]));

  final RecommendationService _service;
  final String? _locale;

  Future<void> search(String query) async {
    log('SearchResultsNotifier.search called with query: ' + query);
    if (query.isEmpty) {
      log('Query is empty, clearing search results');
      state = const AsyncValue.data(<Place>[]);
      return;
    }
    log('Setting search state to loading');
    state = const AsyncValue.loading();
    try {
      log(
        'Calling recommendation service with query: ' +
            query +
            (_locale != null ? ', languageCode: $_locale' : ''),
      );
      final results = await _service.search(query, languageCode: _locale);
      log('Search returned ${results.length} results');
      state = AsyncValue.data(results);
    } catch (e, st) {
      log('Search error: ' + e.toString(), error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

final searchResultsProvider =
    StateNotifierProvider<SearchResultsNotifier, AsyncValue<List<Place>>>((
      ref,
    ) {
      final service = ref.watch(recommendationServiceProvider);
      final locale = ref.watch(localeProvider);
      return SearchResultsNotifier(service, locale?.languageCode);
    });
