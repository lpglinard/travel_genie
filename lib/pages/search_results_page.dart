import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place.dart';
import '../providers/search_results_provider.dart';
import '../l10n/app_localizations.dart';
import 'place_detail_page.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key, required this.query});

  final String query;

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(searchResultsProvider.notifier).search(widget.query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.query)),
      body: results.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).noResults));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final place = list[index];
              return Card(
                child: ListTile(
                  leading: place.photos.isNotEmpty && place.photos.first.url != null
                      ? Image.network(
                          place.photos.first.url!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(width: 60, height: 60),
                  title: Text(place.displayName),
                  subtitle: place.rating != null
                      ? Row(
                          children: [
                            const Icon(Icons.star, size: 16),
                            const SizedBox(width: 4),
                            Text(place.rating!.toString()),
                          ],
                        )
                      : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlaceDetailPage(place: place),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }
}
