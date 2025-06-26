import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/user_providers.dart';
import '../services/groups_service.dart';
import '../widgets/groups/feedback_card.dart';
import '../widgets/groups/feedback_summary.dart';

// Provider for groups service
final groupsServiceProvider = Provider<GroupsService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return GroupsService(firestoreService);
});

final groupsFeedbackProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final groupsService = ref.watch(groupsServiceProvider);
  return groupsService.streamGroupsFeedbackSummary();
});

final userFeedbackProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final groupsService = ref.watch(groupsServiceProvider);
  return groupsService.streamUserFeedback();
});

class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  Future<void> _submitFeedback(WidgetRef ref, bool wantsGroupFeature) async {
    final groupsService = ref.read(groupsServiceProvider);

    try {
      await groupsService.submitFeedback(wantsGroupFeature);

      // Show success message
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(ref.context).groupsFeedbackThanks,
            ),
            backgroundColor: Theme.of(ref.context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(ref.context).errorGeneric(e.toString()),
            ),
            backgroundColor: Theme.of(ref.context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final summaryAsync = ref.watch(groupsFeedbackProvider);
    final userFeedbackAsync = ref.watch(userFeedbackProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navGroups),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                            theme.colorScheme.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.groupsTitle,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.groupsSubtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Feedback question - only show if user hasn't submitted feedback yet
                    if (userFeedbackAsync.valueOrNull == null) ...[
                      FeedbackCard(
                        question: l10n.groupsFeedbackQuestion,
                        description: l10n.groupsFeedbackDescription,
                        userResponse: null,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Summary section
                    summaryAsync.when(
                      data: (summary) => FeedbackSummary(
                        yesCount: summary?['yesCount'] ?? 0,
                        noCount: summary?['noCount'] ?? 0,
                        totalResponses: summary?['totalResponses'] ?? 0,
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.errorGeneric(error.toString()),
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),

                    // Add bottom padding - more when buttons are shown, less when not
                    SizedBox(
                      height: userFeedbackAsync.valueOrNull == null ? 100 : 24,
                    ),
                  ],
                ),
              ),
            ),

            // Fixed bottom button area - only show if user hasn't submitted feedback yet
            if (userFeedbackAsync.valueOrNull == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _submitFeedback(ref, false),
                          icon: const Icon(Icons.thumb_down_rounded),
                          label: Text(l10n.groupsFeedbackNo),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _submitFeedback(ref, true),
                          icon: const Icon(Icons.thumb_up_rounded),
                          label: Text(l10n.groupsFeedbackYes),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
