import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/trip_participant.dart';

class TripParticipantsAvatars extends StatelessWidget {
  const TripParticipantsAvatars({
    super.key,
    required this.participants,
    this.maxVisible = 3,
  });

  final List<TripParticipant> participants;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ...participants
              .take(maxVisible)
              .map(
                (participant) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ParticipantAvatar(participant: participant),
                ),
              ),
          if (participants.length > maxVisible)
            _MoreParticipantsIndicator(count: participants.length - maxVisible),
        ],
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({required this.participant});

  final TripParticipant participant;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF5B6EFF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.star, size: 10, color: Colors.white),
            ),
          ),
      ],
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

class _MoreParticipantsIndicator extends StatelessWidget {
  const _MoreParticipantsIndicator({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      child: Text(
        '+$count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
