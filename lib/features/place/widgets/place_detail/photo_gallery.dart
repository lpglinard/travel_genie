import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/config/config.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/place.dart';

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({
    super.key,
    required this.place,
    required this.initialIndex,
  });

  final Place place;
  final int initialIndex;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(
            context,
          ).imageCount('${currentIndex + 1}', '${widget.place.photos.length}'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int i) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                  widget.place.photos[i].urlWithKey(googlePlacesApiKey),
                ),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            itemCount: widget.place.photos.length,
            loadingBuilder: (context, event) => Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                ),
              ),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: widget.initialIndex),
            onPageChanged: (i) {
              setState(() {
                currentIndex = i;
              });
            },
          ),
          if (widget.place.photos[currentIndex].authorAttributions.isNotEmpty)
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: Colors.black.withOpacity(0.5),
                child: Text(
                  AppLocalizations.of(context).photoBy(
                    widget.place.photos[currentIndex].authorAttributions
                        .map((attr) => attr.displayName)
                        .join(", "),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
