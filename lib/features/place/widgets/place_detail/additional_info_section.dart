import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../models/place.dart';
import 'info_item.dart';
import 'opening_hours_bottom_sheet.dart';

class AdditionalInfoSection extends StatelessWidget {
  const AdditionalInfoSection({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).additionalInfo,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Opening hours
        if (place.openingHours.isNotEmpty) ...[
          InfoItem(
            icon: Icons.access_time,
            title: place.openingHours.first.contains('Open')
                ? AppLocalizations.of(context).openNow
                : AppLocalizations.of(context).closedNow,
            subtitle: AppLocalizations.of(context).tapForHours,
            onTap: () => _showOpeningHours(context),
          ),
          const Divider(),
        ],

        // Price range (mock data since it's not in the model)
        InfoItem(
          icon: Icons.attach_money,
          title: AppLocalizations.of(context).price,
          subtitle: AppLocalizations.of(context).free,
        ),
        const Divider(),

        // Contact
        if (place.websiteUri != null) ...[
          InfoItem(
            icon: Icons.language,
            title: AppLocalizations.of(context).website,
            subtitle: AppLocalizations.of(context).visitWebsite,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              final uri = Uri.parse(place.websiteUri!);
              launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
          const Divider(),
        ],

        // Google Maps
        InfoItem(
          icon: Icons.map,
          title: AppLocalizations.of(context).viewOnGoogleMaps,
          subtitle: AppLocalizations.of(context).openInExternalApp,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            final uri = Uri.parse(place.googleMapsUri);
            launchUrl(uri, mode: LaunchMode.externalApplication);
          },
        ),
        const Divider(),

        // Average visit time (mock data)
        InfoItem(
          icon: Icons.timelapse,
          title: AppLocalizations.of(context).averageVisitTime,
          subtitle: AppLocalizations.of(context).oneToTwoHours,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  void _showOpeningHours(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          OpeningHoursBottomSheet(openingHours: place.openingHours),
    );
  }
}
