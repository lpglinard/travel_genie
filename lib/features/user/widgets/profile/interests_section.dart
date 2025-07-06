import 'package:flutter/material.dart';
import 'package:travel_genie/features/user/models/traveler_profile_enums.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import 'section_card.dart';

class InterestsSection extends StatelessWidget {
  const InterestsSection({
    super.key,
    required this.selectedInterests,
    required this.onChanged,
  });

  final List<TravelInterest> selectedInterests;
  final ValueChanged<List<TravelInterest>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionCard(
      icon: Icons.favorite,
      title: l10n.travelerProfileInterestsTitle,
      child: Column(
        children: TravelInterest.values.map((interest) {
          final isSelected = selectedInterests.contains(interest);
          return CheckboxListTile(
            title: Text(_getInterestLabel(context, interest)),
            value: isSelected,
            onChanged: (bool? value) {
              final newList = List<TravelInterest>.from(selectedInterests);
              if (value == true) {
                newList.add(interest);
              } else {
                newList.remove(interest);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }

  String _getInterestLabel(BuildContext context, TravelInterest interest) {
    final l10n = AppLocalizations.of(context)!;
    switch (interest) {
      case TravelInterest.culture:
        return l10n.travelerProfileInterestsCulture;
      case TravelInterest.nature:
        return l10n.travelerProfileInterestsNature;
      case TravelInterest.nightlife:
        return l10n.travelerProfileInterestsNightlife;
      case TravelInterest.gastronomy:
        return l10n.travelerProfileInterestsGastronomy;
      case TravelInterest.shopping:
        return l10n.travelerProfileInterestsShopping;
      case TravelInterest.relaxation:
        return l10n.travelerProfileInterestsRelaxation;
    }
  }
}
