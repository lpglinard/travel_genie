import 'package:flutter/material.dart';

/// Widget that displays the empty state message
class EmptyStateMessage extends StatelessWidget {
  const EmptyStateMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.map_outlined,
          size: 80,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          'No trips saved yet',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Your saved trips will appear here',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}