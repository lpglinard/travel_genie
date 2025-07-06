import 'package:flutter/material.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import 'friend_list_item.dart';

/// Friends list tab content
/// Follows Single Responsibility Principle - only handles friends list display
class FriendsListTab extends StatelessWidget {
  const FriendsListTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock friends data - in a real app, this would come from a provider
    final friends = [
      {'name': 'Alice Johnson', 'email': 'alice@example.com', 'avatar': null},
      {'name': 'Bob Smith', 'email': 'bob@example.com', 'avatar': null},
      {'name': 'Charlie Brown', 'email': 'charlie@example.com', 'avatar': null},
    ];

    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noFriendsFound,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.addFriendsToInvite,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return FriendListItem(
          name: friend['name'] as String,
          email: friend['email'] as String,
          avatarUrl: friend['avatar'] as String?,
          onInvite: () => _inviteFriend(context, friend['name'] as String),
        );
      },
    );
  }

  void _inviteFriend(BuildContext context, String friendName) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.invitationSentTo(friendName),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}