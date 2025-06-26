import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget that displays the explore button
class ExploreButton extends StatelessWidget {
  const ExploreButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigate to explore page
        context.go('/explore');
      },
      icon: const Icon(Icons.search),
      label: const Text('Explore Destinations'),
    );
  }
}
