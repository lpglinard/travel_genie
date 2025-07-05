import 'package:flutter/material.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/features/user/models/traveler_profile_enums.dart';
import 'section_card.dart';

class GastronomicSection extends StatelessWidget {
  const GastronomicSection({
    super.key,
    required this.selectedPreferences,
    required this.onChanged,
  });

  final List<GastronomicPreference> selectedPreferences;
  final ValueChanged<List<GastronomicPreference>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionCard(
      icon: Icons.restaurant,
      title: l10n.travelerProfileGastronomicTitle,
      child: Column(
        children: GastronomicPreference.values.map((preference) {
          final isSelected = selectedPreferences.contains(preference);
          return CheckboxListTile(
            title: Text(_getGastronomicLabel(context, preference)),
            value: isSelected,
            onChanged: (bool? value) {
              final newList = List<GastronomicPreference>.from(
                selectedPreferences,
              );
              if (value == true) {
                newList.add(preference);
              } else {
                newList.remove(preference);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }

  String _getGastronomicLabel(
    BuildContext context,
    GastronomicPreference preference,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (preference) {
      case GastronomicPreference.localFood:
        return l10n.travelerProfileGastronomicLocal;
      case GastronomicPreference.gourmetRestaurants:
        return l10n.travelerProfileGastronomicGourmet;
      case GastronomicPreference.dietaryRestrictions:
        return l10n.travelerProfileGastronomicDietary;
    }
  }
}