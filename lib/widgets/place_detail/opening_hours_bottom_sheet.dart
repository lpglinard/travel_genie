import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class OpeningHoursBottomSheet extends StatelessWidget {
  const OpeningHoursBottomSheet({
    super.key,
    required this.openingHours,
  });

  final List<String> openingHours;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).openingHours,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...openingHours
              .map(
                (hour) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    hour,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context).close,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}