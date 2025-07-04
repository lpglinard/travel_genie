import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import '../models/trip_participant.dart';

class ParticipantListItem extends StatelessWidget {
  const ParticipantListItem({super.key, required this.participant, this.onTap});

  final TripParticipant participant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            backgroundImage: participant.avatarUrl?.isNotEmpty == true
                ? CachedNetworkImageProvider(participant.avatarUrl!)
                : null,
            child: participant.avatarUrl?.isEmpty != false
                ? Text(
                    _getInitials(participant.displayName),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          if (participant.isOrganizer)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6EFF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: const Icon(Icons.star, size: 8, color: Colors.white),
              ),
            ),
        ],
      ),
      title: Text(
        participant.displayName,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        participant.isOrganizer
            ? AppLocalizations.of(context)!.organizer
            : AppLocalizations.of(context)!.participant,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: participant.isOrganizer
              ? const Color(0xFF5B6EFF)
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: participant.isOrganizer
              ? FontWeight.w600
              : FontWeight.normal,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
          .toUpperCase();
    }
  }
}
