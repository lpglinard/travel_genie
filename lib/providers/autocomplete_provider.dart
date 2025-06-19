import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/places_service.dart';
import '../user_providers.dart';

class AutocompleteNotifier extends StateNotifier<AsyncValue<List<String>>> {
  AutocompleteNotifier(this._service)
      : super(const AsyncValue.data(<String>[])) {
    print('AutocompleteNotifier created');
  }

  final PlacesService _service;
  Timer? _debounce;

  void search(String query) {
    print('search called with: $query');
    _debounce?.cancel();
    if (query.isEmpty) {
      print('query is empty, clearing suggestions');
      state = const AsyncValue.data(<String>[]);
      return;
    }
    print('starting debounce timer');
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      print('fetching suggestions for "$query"');
      state = const AsyncValue.loading();
      try {
        final results = await _service.autocomplete(
          query,
          maxResults: 5,
          regionCode: 'br',
        );
        print('autocomplete returned ${results.length} results');
        state = AsyncValue.data(results);
      } catch (e, st) {
        print('autocomplete error: $e');
        state = AsyncValue.error(e, st);
      }
    });
  }

  @override
  void dispose() {
    print('AutocompleteNotifier disposed');
    _debounce?.cancel();
    super.dispose();
  }
}

final autocompleteProvider =
    StateNotifierProvider<AutocompleteNotifier, AsyncValue<List<String>>>(
        (ref) {
  final service = ref.watch(placesServiceProvider);
  return AutocompleteNotifier(service);
});
