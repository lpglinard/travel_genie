import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/place.dart';

class LocationMapSection extends StatelessWidget {
  const LocationMapSection({
    super.key,
    required this.place,
  });

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).location,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.map,
                    size: 64,
                    color: Colors.grey.shade700,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary,
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).openInMaps,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}