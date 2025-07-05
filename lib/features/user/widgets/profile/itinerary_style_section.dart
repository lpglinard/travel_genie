import 'package:flutter/material.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/features/user/models/traveler_profile_enums.dart';
import 'section_card.dart';

class ItineraryStyleSection extends StatelessWidget {
  const ItineraryStyleSection({
    super.key,
    required this.selectedStyle,
    required this.onChanged,
  });

  final ItineraryStyle? selectedStyle;
  final ValueChanged<ItineraryStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionCard(
      icon: Icons.map,
      title: l10n.travelerProfileItineraryTitle,
      child: Column(
        children: ItineraryStyle.values.map((style) {
          return RadioListTile<ItineraryStyle>(
            title: Text(_getItineraryStyleLabel(context, style)),
            value: style,
            groupValue: selectedStyle,
            onChanged: (ItineraryStyle? value) {
              if (value != null) {
                onChanged(value);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _getItineraryStyleLabel(BuildContext context, ItineraryStyle style) {
    final l10n = AppLocalizations.of(context)!;
    switch (style) {
      case ItineraryStyle.detailed:
        return l10n.travelerProfileItineraryDetailed;
      case ItineraryStyle.spontaneous:
        return l10n.travelerProfileItinerarySpontaneous;
    }
  }
}