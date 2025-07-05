import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.isSaved,
    required this.isLoading,
    required this.onSavePressed,
  });

  final bool isSaved;
  final bool isLoading;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onSavePressed,
            icon: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
            label: Text(
              isLoading
                  ? AppLocalizations.of(context).close
                  : AppLocalizations.of(context).save,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              disabledBackgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.6),
              disabledForegroundColor: Theme.of(
                context,
              ).colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
