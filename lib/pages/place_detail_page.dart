import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../l10n/app_localizations.dart';
import '../models/place.dart';
import '../config.dart';

class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({
    super.key, 
    required this.place, 
    this.heroTagIndex,
  });

  final Place place;
  final int? heroTagIndex;

  void _openGallery(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            int currentIndex = index;
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                title: Text('${currentIndex + 1} / ${place.photos.length}'),
              ),
              body: Stack(
                children: [
                  PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int i) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: CachedNetworkImageProvider(
                          place.photos[i].urlWithKey(googlePlacesApiKey),
                        ),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      );
                    },
                    itemCount: place.photos.length,
                    loadingBuilder: (context, event) => Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                        ),
                      ),
                    ),
                    backgroundDecoration: const BoxDecoration(color: Colors.black),
                    pageController: PageController(initialPage: index),
                    onPageChanged: (i) {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                  ),
                  if (place.photos[currentIndex].authorAttributions.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.black.withOpacity(0.5),
                        child: Text(
                          'Photo by: ${place.photos[currentIndex].authorAttributions.map((attr) => attr.displayName).join(", ")}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.displayName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (place.photos.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _openGallery(context, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Hero(
                          tag: heroTagIndex != null 
                              ? 'place-image-${place.placeId}-$heroTagIndex' 
                              : 'place-image-${place.placeId}',
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
                      ),
                    ),
                    if (place.photos.first.authorAttributions.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          color: Colors.black.withOpacity(0.5),
                          child: Text(
                            'Photo by: ${place.photos.first.authorAttributions.map((attr) => attr.displayName).join(", ")}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                  ],
                ),
                if (place.photos.length > 1)
                  Container(
                    height: 80,
                    margin: const EdgeInsets.only(top: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: place.photos.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _openGallery(context, index),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: place.photos[index].urlWithKey(googlePlacesApiKey),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.broken_image, size: 24),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
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
