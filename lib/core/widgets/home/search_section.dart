import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/features/search/providers/autocomplete_provider.dart';
import 'package:travel_genie/features/search/widgets/search_field.dart';
import 'package:travel_genie/features/user/providers/user_providers.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

class SearchSection extends ConsumerStatefulWidget {
  const SearchSection({super.key});

  @override
  ConsumerState<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends ConsumerState<SearchSection> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    if (value.isNotEmpty) {
      ref.read(analyticsServiceProvider).logSearchPlace(searchTerm: value);
      ref.read(autocompleteProvider.notifier).search('');
      // Use go_router to navigate to the explore page with the query parameter
      context.go('/explore?query=$value');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: formKey,
          child: SearchField(
            controller: searchController,
            hintText: AppLocalizations.of(context).searchPlaceholder,
            onChanged: (value) {
              ref.read(autocompleteProvider.notifier).search(value);
            },
            onSubmitted: _submitSearch,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _submitSearch(searchController.text),
            ),
          ),
        ),
        _buildSuggestions(),
      ],
    );
  }

  Widget _buildSuggestions() {
    final suggestions = ref.watch(autocompleteProvider);
    return suggestions.maybeWhen(
      data: (list) => list.isEmpty
          ? const SizedBox.shrink()
          : Column(
              children: list
                  .map(
                    (s) => ListTile(
                      title: Text(
                        s,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      onTap: () {
                        // Search tracking will be handled by _submitSearch method
                        searchController.text = s;
                        _submitSearch(s);
                      },
                    ),
                  )
                  .toList(),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
