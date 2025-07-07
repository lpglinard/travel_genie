import 'package:flutter/material.dart';
import 'package:travel_genie/core/extensions/challenge_localization_extension.dart';
import 'package:travel_genie/features/challenge/models/challenge.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

class ChallengeItem extends StatelessWidget {
  const ChallengeItem({super.key, required this.challenge, this.onTap});

  final Challenge challenge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n.challengeTitleFromKey(challenge.titleKey);
    final description = l10n.challengeDescriptionFromKey(
      challenge.descriptionKey,
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.0,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ],
      ),
    );
  }
}
