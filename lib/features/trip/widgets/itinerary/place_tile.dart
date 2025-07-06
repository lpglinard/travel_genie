

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/features/place/models/place.dart';

/// Widget that displays a single place in the itinerary
/// Follows Single Responsibility Principle - only handles place tile display
class PlaceTile extends StatelessWidget {
  const PlaceTile({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Navigate to place detail page
        context.push('/place/${place.placeId}', extra: place);
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          _getPlaceIcon(place.category.id.toString()),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        place.displayName,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (place.formattedAddress.isNotEmpty)
            Text(
              place.formattedAddress,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          Row(
            children: [
              if (place.rating != null) ...[
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${place.rating!.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                if (place.userRatingCount != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${place.userRatingCount})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
              if (place.rating != null &&
                  place.estimatedDurationMinutes != null)
                const SizedBox(width: 12),
              if (place.estimatedDurationMinutes != null) ...[
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${place.estimatedDurationMinutes}min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPlaceIcon(String categoryId) {
    switch (categoryId) {
      case 'restaurant':
        return Icons.restaurant;
      case 'tourist_attraction':
        return Icons.attractions;
      case 'lodging':
        return Icons.hotel;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.theater_comedy;
      case 'transportation':
        return Icons.directions_transit;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'finance':
        return Icons.account_balance;
      case 'government':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }
}