import 'package:flutter/material.dart';
import 'package:travel_genie/features/user/models/traveler_profile_enums.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import 'section_card.dart';

class AccommodationSection extends StatelessWidget {
  const AccommodationSection({
    super.key,
    required this.selectedTypes,
    required this.onChanged,
  });

  final List<AccommodationType> selectedTypes;
  final ValueChanged<List<AccommodationType>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionCard(
      icon: Icons.hotel,
      title: l10n.travelerProfileAccommodationTitle,
      child: Column(
        children: AccommodationType.values.map((type) {
          final isSelected = selectedTypes.contains(type);
          return CheckboxListTile(
            title: Text(_getAccommodationLabel(context, type)),
            value: isSelected,
            onChanged: (bool? value) {
              final newList = List<AccommodationType>.from(selectedTypes);
              if (value == true) {
                newList.add(type);
              } else {
                newList.remove(type);
              }
              onChanged(newList);
            },
          );
        }).toList(),
      ),
    );
  }

  String _getAccommodationLabel(BuildContext context, AccommodationType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case AccommodationType.hostel:
        return l10n.travelerProfileAccommodationHostel;
      case AccommodationType.budgetHotel:
        return l10n.travelerProfileAccommodationBudgetHotel;
      case AccommodationType.comfortHotel:
        return l10n.travelerProfileAccommodationComfortHotel;
      case AccommodationType.resort:
        return l10n.travelerProfileAccommodationResort;
      case AccommodationType.apartment:
        return l10n.travelerProfileAccommodationApartment;
    }
  }
}
