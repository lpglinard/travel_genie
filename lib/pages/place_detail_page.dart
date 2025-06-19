import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../l10n/app_localizations.dart';
import '../models/place.dart';
import '../config.dart';

class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.displayName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (place.photos.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl:
                    place.photos.first.urlWithKey(googlePlacesApiKey),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            place.displayName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(place.formattedAddress),
          const SizedBox(height: 8),
          if (place.rating != null)
            Row(
              children: [
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 4),
                Text(place.rating!.toString()),
              ],
            ),
          const SizedBox(height: 16),
          if (place.openingHours.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context).openingHours,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            ...place.openingHours.map((e) => Text(e)).toList(),
            const SizedBox(height: 16),
          ],
          TextButton(
            onPressed: () {
              final uri = Uri.parse(place.googleMapsUri);
              launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: Text(AppLocalizations.of(context).openInMaps),
          ),
        ],
      ),
    );
  }
}
