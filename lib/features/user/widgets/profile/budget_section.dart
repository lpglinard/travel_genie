import 'package:flutter/material.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/features/user/models/traveler_profile_enums.dart';
import 'section_card.dart';

class BudgetSection extends StatelessWidget {
  const BudgetSection({
    super.key,
    required this.selectedBudget,
    required this.onChanged,
  });

  final TravelBudget? selectedBudget;
  final ValueChanged<TravelBudget> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionCard(
      icon: Icons.attach_money,
      title: l10n.travelerProfileBudgetTitle,
      child: Column(
        children: TravelBudget.values.map((budget) {
          return RadioListTile<TravelBudget>(
            title: Text(_getBudgetLabel(context, budget)),
            value: budget,
            groupValue: selectedBudget,
            onChanged: (TravelBudget? value) {
              if (value != null) {
                onChanged(value);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _getBudgetLabel(BuildContext context, TravelBudget budget) {
    final l10n = AppLocalizations.of(context)!;
    switch (budget) {
      case TravelBudget.economic:
        return l10n.travelerProfileBudgetEconomic;
      case TravelBudget.moderate:
        return l10n.travelerProfileBudgetModerate;
      case TravelBudget.luxury:
        return l10n.travelerProfileBudgetLuxury;
    }
  }
}