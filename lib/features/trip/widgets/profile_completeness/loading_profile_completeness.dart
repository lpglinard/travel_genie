import 'package:flutter/material.dart';

/// Loading state for profile completeness
/// Follows Single Responsibility Principle - only handles loading state display
class LoadingProfileCompleteness extends StatelessWidget {
  const LoadingProfileCompleteness({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shimmer effect for progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        // Shimmer effect for text
        Container(
          height: 16,
          width: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        // Shimmer effect for button
        Container(
          height: 36,
          width: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ],
    );
  }
}
