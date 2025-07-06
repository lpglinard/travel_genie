import 'package:flutter/material.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import 'travel_partner_invite_modal.dart';

/// Widget that provides travel partner invitation functionality
/// Follows Single Responsibility Principle - only handles travel partner invitation
class TravelPartnerInviteWidget extends StatelessWidget {
  const TravelPartnerInviteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: () => _showInviteModal(context),
        icon: Icon(
          Icons.add,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        label: Text(
          AppLocalizations.of(context)!.inviteTravelPartner,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showInviteModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TravelPartnerInviteModal(),
    );
  }
}