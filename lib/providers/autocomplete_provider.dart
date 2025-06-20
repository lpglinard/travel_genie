import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/places_service.dart';
import './user_providers.dart';

class AutocompleteNotifier extends StateNotifier<AsyncValue<List<String>>> {
  AutocompleteNotifier(this._service)
    : super(const AsyncValue.data(<String>[]));

  final PlacesService _service;
  Timer? _debounce;

  void search(String query) {
    log('AutocompleteNotifier.search called with query: ' + query);
    _debounce?.cancel();
    if (query.isEmpty) {
      log('Query is empty, clearing suggestions');
      state = const AsyncValue.data(<String>[]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      log('Triggering autocomplete for query: ' + query);
      state = const AsyncValue.loading();
      try {
        final results = await _service.autocomplete(query, regionCode: 'br');
        log('Autocomplete returned ' + results.length.toString() + ' results');
        state = AsyncValue.data(results);
      } catch (e, st) {
        log('Autocomplete error: ' + e.toString(), error: e, stackTrace: st);
        state = AsyncValue.error(e, st);
      }
    });
  }

  @override
  void dispose() {
    log('Disposing AutocompleteNotifier');
    _debounce?.cancel();
    super.dispose();
  }
}

final autocompleteProvider =
    StateNotifierProvider<AutocompleteNotifier, AsyncValue<List<String>>>((
      ref,
    ) {
      final service = ref.watch(placesServiceProvider);
      return AutocompleteNotifier(service);
    });
