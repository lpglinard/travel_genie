import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

/// Optimization strategies available for the magic AI trip optimizer
enum OptimizationStrategy { timeEfficient, costEffective, experienceMaximizer }

/// A bottom sheet that allows users to select a trip optimization strategy
/// and start the magic AI optimization process.
class MagicAiOptimizerBottomSheet extends ConsumerStatefulWidget {
  /// Callback function called when the user starts the optimization process
  final Function(OptimizationStrategy strategy) onOptimizationStart;

  const MagicAiOptimizerBottomSheet({
    super.key,
    required this.onOptimizationStart,
  });

  @override
  ConsumerState<MagicAiOptimizerBottomSheet> createState() =>
      _MagicAiOptimizerBottomSheetState();
}

class _MagicAiOptimizerBottomSheetState
    extends ConsumerState<MagicAiOptimizerBottomSheet> {
  OptimizationStrategy? _selectedStrategy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.magicAiTripOptimizer,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            l10n.chooseOptimizationStrategy,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Strategy options
          _buildStrategyOption(
            strategy: OptimizationStrategy.timeEfficient,
            icon: Icons.schedule,
            title: l10n.timeEfficient,
            description: l10n.timeEfficientDescription,
            theme: theme,
          ),
          const SizedBox(height: 16),

          _buildStrategyOption(
            strategy: OptimizationStrategy.costEffective,
            icon: Icons.savings,
            title: l10n.costEffective,
            description: l10n.costEffectiveDescription,
            theme: theme,
          ),
          const SizedBox(height: 16),

          _buildStrategyOption(
            strategy: OptimizationStrategy.experienceMaximizer,
            icon: Icons.star,
            title: l10n.experienceMaximizer,
            description: l10n.experienceMaximizerDescription,
            theme: theme,
          ),
          const SizedBox(height: 32),

          // Start button
          ElevatedButton(
            onPressed: _selectedStrategy != null
                ? () {
                    // Analytics tracking will be handled when optimization actually starts
                    Navigator.of(context).pop();
                    widget.onOptimizationStart(_selectedStrategy!);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_fix_high, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.startMagicOptimization,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStrategyOption({
    required OptimizationStrategy strategy,
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    final isSelected = _selectedStrategy == strategy;

    return GestureDetector(
      onTap: () {
        // Removed granular widget interaction tracking as per analytics strategy refactor
        setState(() {
          _selectedStrategy = strategy;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
