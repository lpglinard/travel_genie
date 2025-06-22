import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/config.dart';
import '../../core/extensions/string_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import 'photo_attribution.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.place,
    required this.index,
    required this.query,
  });

  final Place place;
  final int index;
  final String query;

  // Helper method to format rating count (e.g., 1200 -> 1.2k)
  String _formatRatingCount(int count) {
    if (count >= 1000) {
      final double countInK = count / 1000;
      return '${countInK.toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Get the first type or use a default
    String placeType = place.types.isNotEmpty
        ? place.types.first.replaceAll('_', ' ').capitalize()
        : AppLocalizations.of(context).defaultPlaceType;

    // Extract location from formatted address (simplified)
    String location = place.formattedAddress.split(',').length > 1
        ? place.formattedAddress.split(',')[1].trim()
        : '';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to place detail using go_router with push
          context.push(
            '/place/${place.placeId}?query=${Uri.encodeComponent(query)}',
            extra: {'place': place, 'heroTagIndex': index},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            SizedBox(
              width: double.infinity,
              height: 200, // Fixed height for all images
              child: place.photos.isNotEmpty
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Hero(
                              tag: 'place-image-${place.placeId}-$index',
                              child: CachedNetworkImage(
                                imageUrl: place.photos.first.urlWithKey(
                                  googlePlacesApiKey,
                                ),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (place.photos.isNotEmpty)
                          PhotoAttribution(photo: place.photos.first),
                      ],
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 40),
                    ),
            ),

            // Text content section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category with icon and background color
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? place.category.lightColor
                              : place.category.darkColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              place.category.icon,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.category.name,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Title
                  Text(
                    place.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Generative Summary
                  if (place.generativeSummary.isNotEmpty)
                    Text(
                      place.generativeSummary,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Disclosure Text
                  if (place.disclosureText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      place.disclosureText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Rating and reviews
                  if (place.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).stars(place.rating!.toString()),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (place.userRatingCount != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context).reviews(
                              _formatRatingCount(place.userRatingCount!),
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
