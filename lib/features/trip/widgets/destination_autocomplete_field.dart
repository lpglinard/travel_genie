import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import '../models/place_suggestion.dart';
import '../services/city_autocomplete_service.dart';

/// Widget that provides destination autocomplete functionality using Flutter's Autocomplete widget
/// Follows Single Responsibility Principle - only handles destination input with autocomplete
class DestinationAutocompleteField extends ConsumerStatefulWidget {
  const DestinationAutocompleteField({
    super.key,
    required this.controller,
    this.onDestinationSelected,
    this.onSuggestionSelected,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onDestinationSelected;
  final ValueChanged<PlaceSuggestion>? onSuggestionSelected;

  @override
  ConsumerState<DestinationAutocompleteField> createState() =>
      _DestinationAutocompleteFieldState();
}

class _DestinationAutocompleteFieldState
    extends ConsumerState<DestinationAutocompleteField> {
  List<PlaceSuggestion> _lastSuggestions = [];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<PlaceSuggestion>(
      displayStringForOption: (PlaceSuggestion option) =>
          option.placePrediction.displayText,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        final query = textEditingValue.text.trim();
        if (query.length < 2) {
          _lastSuggestions = [];
          return const Iterable<PlaceSuggestion>.empty();
        }

        try {
          final cityService = ref.read(cityAutocompleteServiceProvider);
          final suggestions = await cityService.searchCities(query);
          _lastSuggestions = suggestions;
          return suggestions;
        } catch (e) {
          _lastSuggestions = [];
          return const Iterable<PlaceSuggestion>.empty();
        }
      },
      onSelected: (PlaceSuggestion selection) {
        widget.controller.text = selection.placePrediction.displayText;
        widget.onDestinationSelected?.call(
          selection.placePrediction.displayText,
        );
        widget.onSuggestionSelected?.call(selection);
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Sync the provided controller with the field controller
            fieldTextEditingController.text = widget.controller.text;
            fieldTextEditingController.addListener(() {
              if (widget.controller.text != fieldTextEditingController.text) {
                widget.controller.text = fieldTextEditingController.text;
              }
            });
            widget.controller.addListener(() {
              if (fieldTextEditingController.text != widget.controller.text) {
                fieldTextEditingController.text = widget.controller.text;
              }
            });

            return TextFormField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.destinationLabel,
                hintText: AppLocalizations.of(context)!.destinationPlaceholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.destinationRequired;
                }
                return null;
              },
              onFieldSubmitted: (value) => onFieldSubmitted(),
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<PlaceSuggestion> onSelected,
            Iterable<PlaceSuggestion> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    maxWidth: 300,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: options.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            AppLocalizations.of(context)!.noResults,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final PlaceSuggestion option = options.elementAt(
                              index,
                            );
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.location_city,
                                size: 20,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              title: Text(
                                option.placePrediction.displayText,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                ),
              ),
            );
          },
    );
  }
}
