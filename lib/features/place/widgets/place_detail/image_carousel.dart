import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/config.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/place.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.place,
    this.heroTagIndex,
    required this.onGalleryOpen,
  });

  final Place place;
  final int? heroTagIndex;
  final Function(int) onGalleryOpen;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.place.photos.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => widget.onGalleryOpen(index),
                child: Stack(
                  children: [
                    Hero(
                      tag: widget.heroTagIndex != null
                          ? (index == 0
                                ? 'place-image-${widget.place.placeId}-${widget.heroTagIndex}'
                                : 'place-image-${widget.place.placeId}-${widget.heroTagIndex}-$index')
                          : 'place-image-${widget.place.placeId}-$index',
                      child: CachedNetworkImage(
                        imageUrl: widget.place.photos[index].urlWithKey(
                          googlePlacesApiKey,
                        ),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    ),
                    if (widget
                        .place
                        .photos[index]
                        .authorAttributions
                        .isNotEmpty)
                      Positioned(
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
                              widget.place.photos[index].authorAttributions
                                  .map((attr) => attr.displayName)
                                  .join(", "),
                            ),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.place.photos.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.place.photos.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
