import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class FeedbackSummary extends StatelessWidget {
  const FeedbackSummary({
    super.key,
    required this.yesCount,
    required this.noCount,
    required this.totalResponses,
  });

  final int yesCount;
  final int noCount;
  final int totalResponses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (totalResponses == 0) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.groupsFeedbackSummaryEmpty,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final yesPercentage = (yesCount / totalResponses * 100).round();
    final noPercentage = (noCount / totalResponses * 100).round();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.groupsFeedbackSummaryTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        l10n.groupsFeedbackSummarySubtitle(totalResponses),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: theme.colorScheme.surfaceVariant,
              ),
              child: Row(
                children: [
                  if (yesCount > 0)
                    Expanded(
                      flex: yesCount,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(6),
                            bottomLeft: const Radius.circular(6),
                            topRight: noCount == 0
                                ? const Radius.circular(6)
                                : Radius.zero,
                            bottomRight: noCount == 0
                                ? const Radius.circular(6)
                                : Radius.zero,
                          ),
                        ),
                      ),
                    ),
                  if (noCount > 0)
                    Expanded(
                      flex: noCount,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.8,
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: const Radius.circular(6),
                            bottomRight: const Radius.circular(6),
                            topLeft: yesCount == 0
                                ? const Radius.circular(6)
                                : Radius.zero,
                            bottomLeft: yesCount == 0
                                ? const Radius.circular(6)
                                : Radius.zero,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.thumb_up_rounded,
                    label: l10n.groupsFeedbackYes,
                    count: yesCount,
                    percentage: yesPercentage,
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.thumb_down_rounded,
                    label: l10n.groupsFeedbackNo,
                    count: noCount,
                    percentage: noPercentage,
                    color: theme.colorScheme.onSurfaceVariant,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Encouraging message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('✨', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getEncouragingMessage(context, yesPercentage),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required int percentage,
    required Color color,
    required Color backgroundColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$percentage%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getEncouragingMessage(BuildContext context, int yesPercentage) {
    final l10n = AppLocalizations.of(context);

    if (yesPercentage >= 80) {
      return l10n.groupsFeedbackEncouragingHigh;
    } else if (yesPercentage >= 60) {
      return l10n.groupsFeedbackEncouragingMedium;
    } else if (yesPercentage >= 40) {
      return l10n.groupsFeedbackEncouragingLow;
    } else {
      return l10n.groupsFeedbackEncouragingVeryLow;
    }
  }
}
