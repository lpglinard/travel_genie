import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import '../../models/place_type.dart';

class PlaceInfoSection extends StatelessWidget {
  const PlaceInfoSection({
    super.key,
    required this.place,
  });

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Place name
        Text(
          place.displayName,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        // Address
        Text(
          place.formattedAddress,
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 8),

        // Category and rating
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category with icon and background color
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? place.category.lightColor
                    : place.category.darkColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    place.category.icon,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    place.category.name,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Place types in a wrapping row
            if (place.types.isNotEmpty)
              Wrap(
                spacing: 8, // gap between adjacent chips
                runSpacing: 4, // gap between lines
                children: place.types.map((type) {
                  return Chip(
                    label: Text(
                      PlaceType.getLocalizedName(context, type),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  );
                }).toList(),
              ),

            // Rating information
            if (place.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    place.rating!.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (place.userRatingCount != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${place.userRatingCount} reviews)',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}