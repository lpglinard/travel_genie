import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../models/place.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    if (place.generativeSummary.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).description,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          place.generativeSummary,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (place.disclosureText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            place.disclosureText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
