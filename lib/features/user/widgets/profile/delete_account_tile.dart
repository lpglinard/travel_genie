import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/features/user/providers/user_providers.dart';

class DeleteAccountTile extends ConsumerWidget {
  const DeleteAccountTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);

    return userAsync.when(
      data: (user) {
        // Only show delete account option for authenticated users
        if (user == null) {
          return const SizedBox.shrink();
        }

        return _buildDeleteAccountTile(context, ref, user);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDeleteAccountTile(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: Text(
        AppLocalizations.of(context)!.deleteAccount,
        style: const TextStyle(color: Colors.red),
      ),
      onTap: () => _showDeleteAccountDialog(context, ref, user),
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteAccountDialog(),
    );

    if (confirmed == true && context.mounted) {
      await _deleteAccount(context, ref, user);
    }
  }

  Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Clear local preferences first
      final prefs = await ref.read(preferencesServiceProvider.future);
      await prefs.clearAll();

      // Delete user using Firebase's default implementation
      final userManagementService = ref.read(userManagementServiceProvider);
      final deletionResponse = await userManagementService.deleteAllUserData(
        user.uid,
        ref,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Check if deletion was successful
      if (deletionResponse.success) {
        // Show success message and navigate to main screen unauthenticated
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.deleteAccountSuccess),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home and clear navigation stack
          // User will be automatically unauthenticated since Firebase Auth user was deleted
          context.go('/');
        }
      } else {
        // Handle deletion failure
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.deleteAccountError(
                  deletionResponse.errorMessage?.toString() ?? 'Unknown error',
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.deleteAccountError(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _confirmationController = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_checkConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _checkConfirmation() {
    final text = _confirmationController.text.trim().toUpperCase();
    final expectedText =
        AppLocalizations.of(context)!.typeDeleteToConfirm.contains('DELETE')
        ? 'DELETE'
        : 'EXCLUIR';

    setState(() {
      _canDelete = text == expectedText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        localizations.deleteAccountTitle,
        style: const TextStyle(color: Colors.red),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.deleteAccountWarning,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.deleteAccountConfirmation,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.deleteAccountFinalConfirmation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmationController,
              decoration: InputDecoration(
                hintText: localizations.typeDeleteToConfirm,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: _canDelete ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(localizations.deleteAccountButton),
        ),
      ],
    );
  }
}
