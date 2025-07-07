import 'package:flutter/material.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import 'email_invite_tab.dart';
import 'friends_list_tab.dart';
import 'tab_button.dart';

/// Modal for travel partner invitation
/// Follows Single Responsibility Principle - only handles the invite modal UI
class TravelPartnerInviteModal extends StatefulWidget {
  const TravelPartnerInviteModal({super.key});

  @override
  State<TravelPartnerInviteModal> createState() =>
      _TravelPartnerInviteModalState();
}

class _TravelPartnerInviteModalState extends State<TravelPartnerInviteModal> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.inviteTravelPartner,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TabButton(
                    text: AppLocalizations.of(context)!.friends,
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                ),
                Expanded(
                  child: TabButton(
                    text: AppLocalizations.of(context)!.inviteByEmail,
                    isSelected: _selectedTabIndex == 1,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: _selectedTabIndex == 0
                ? const FriendsListTab()
                : const EmailInviteTab(),
          ),
        ],
      ),
    );
  }
}
