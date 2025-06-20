import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/photo.dart';

class PhotoAttribution extends StatelessWidget {
  const PhotoAttribution({
    super.key,
    required this.photo,
  });

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    if (photo.authorAttributions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        color: Colors.black.withOpacity(0.5),
        child: Text(
          AppLocalizations.of(context).photoBy(
            photo.authorAttributions
                .map((attr) => attr.displayName)
                .join(", "),
          ),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}