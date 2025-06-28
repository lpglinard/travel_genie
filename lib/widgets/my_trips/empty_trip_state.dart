import 'package:flutter/material.dart';

import 'empty_state_message.dart';
import 'explore_button.dart';

/// Widget that displays when no trips are available
class EmptyTripState extends StatelessWidget {
  const EmptyTripState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmptyStateMessage(),
          const SizedBox(height: 24),
          const ExploreButton(),
        ],
      ),
    );
  }
}
