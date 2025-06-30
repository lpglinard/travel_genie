import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'example_row.dart';

class FeedbackCard extends StatelessWidget {
  const FeedbackCard({
    super.key,
    required this.question,
    required this.description,
    this.userResponse,
  });

  final String question;
  final String description;
  final bool? userResponse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header with emoji
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('🤔', style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // Examples section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.tertiary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: theme.colorScheme.tertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.groupsFeedbackExamplesTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ExampleRow(
                    emoji: '👨‍👩‍👧‍👦',
                    text: l10n.groupsFeedbackExampleFamily,
                  ),
                  const SizedBox(height: 8),
                  ExampleRow(
                    emoji: '👥',
                    text: l10n.groupsFeedbackExampleFriends,
                  ),
                  const SizedBox(height: 8),
                  ExampleRow(
                    emoji: '💼',
                    text: l10n.groupsFeedbackExampleColleagues,
                  ),
                  const SizedBox(height: 8),
                  ExampleRow(
                    emoji: '💕',
                    text: l10n.groupsFeedbackExamplePartner,
                  ),
                ],
              ),
            ),

            // Current response indicator
            if (userResponse != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: userResponse!
                      ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      userResponse! ? Icons.check_circle : Icons.cancel,
                      color: userResponse!
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      userResponse!
                          ? l10n.groupsFeedbackCurrentResponseYes
                          : l10n.groupsFeedbackCurrentResponseNo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: userResponse!
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
