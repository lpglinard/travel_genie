import 'package:flutter/material.dart';
import 'package:travel_genie/features/user/models/traveler_profile_enums.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import 'section_card.dart';

class TravelCompanySection extends StatelessWidget {
  const TravelCompanySection({
    super.key,
    required this.selectedCompanies,
    required this.onChanged,
  });

  final List<TravelCompany> selectedCompanies;
  final ValueChanged<List<TravelCompany>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionCard(
      icon: Icons.group,
      title: l10n.travelerProfileTravelCompanyTitle,
      child: Column(
        children: TravelCompany.values.map((company) {
          final isSelected = selectedCompanies.contains(company);
          return CheckboxListTile(
            title: Text(_getTravelCompanyLabel(context, company)),
            value: isSelected,
            onChanged: (bool? value) {
              final newList = List<TravelCompany>.from(selectedCompanies);
              if (value == true) {
                newList.add(company);
              } else {
                newList.remove(company);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }

  String _getTravelCompanyLabel(BuildContext context, TravelCompany company) {
    final l10n = AppLocalizations.of(context)!;
    switch (company) {
      case TravelCompany.solo:
        return l10n.travelerProfileTravelCompanySolo;
      case TravelCompany.couple:
        return l10n.travelerProfileTravelCompanyCouple;
      case TravelCompany.familyWithChildren:
        return l10n.travelerProfileTravelCompanyFamily;
      case TravelCompany.friendsGroup:
        return l10n.travelerProfileTravelCompanyFriends;
    }
  }
}
