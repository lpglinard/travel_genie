import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/places_service.dart';
import '../user_providers.dart';

class AutocompleteNotifier extends StateNotifier<AsyncValue<List<String>>> {
  AutocompleteNotifier(this._service)
      : super(const AsyncValue.data(<String>[]));

  final PlacesService _service;
  Timer? _debounce;

  void search(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      state = const AsyncValue.data(<String>[]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      state = const AsyncValue.loading();
      try {
        final results = await _service.autocomplete(
          query,
          maxResults: 5,
          regionCode: 'br',
        );
        state = AsyncValue.data(results);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  @override
  void dispose() {
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
