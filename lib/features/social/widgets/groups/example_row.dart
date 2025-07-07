import 'package:flutter/material.dart';

/// Row widget used in feedback examples list.
class ExampleRow extends StatelessWidget {
  const ExampleRow({super.key, required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onTertiaryContainer.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
