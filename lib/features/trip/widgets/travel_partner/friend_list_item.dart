import 'package:flutter/material.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

/// Friend list item widget
/// Follows Single Responsibility Principle - only handles friend list item display
class FriendListItem extends StatelessWidget {
  const FriendListItem({
    super.key,
    required this.name,
    required this.email,
    required this.onInvite,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        backgroundImage: avatarUrl?.isNotEmpty == true
            ? NetworkImage(avatarUrl!)
            : null,
        child: avatarUrl?.isEmpty != false
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        name,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        email,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: OutlinedButton(
        onPressed: onInvite,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF5B6EFF),
          side: const BorderSide(color: Color(0xFF5B6EFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(AppLocalizations.of(context)!.invite),
      ),
    );
  }
}
