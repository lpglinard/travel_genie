import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/config.dart';
import '../../core/extensions/string_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import '../../providers/user_providers.dart';
import '../login_required_dialog.dart';
import 'photo_attribution.dart';

class SearchResultCard extends ConsumerStatefulWidget {
  const SearchResultCard({
    super.key,
    required this.place,
    required this.index,
    required this.query,
  });

  final Place place;
  final int index;
  final String query;

  @override
  ConsumerState<SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends ConsumerState<SearchResultCard> {
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        final isSaved = await firestoreService.isPlaceSaved(
          user.uid,
          widget.place.placeId,
        );
        if (mounted) {
          setState(() {
            _isSaved = isSaved;
          });
        }
      } catch (e) {
        // Handle error silently for now
        print('Error checking if place is saved: $e');
      }
    }
  }

  Future<void> _toggleSaved() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Show login required dialog
        if (mounted) {
          await LoginRequiredDialog.show(context);
        }
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final firestoreService = ref.read(firestoreServiceProvider);

        if (_isSaved) {
          // Remove from saved places
          await firestoreService.removePlace(user.uid, widget.place.placeId);
          ref
              .read(analyticsServiceProvider)
              .logButtonTap(
                buttonName: 'remove_from_favorites',
                screenName: 'search_results',
                context: 'place_card',
              );
        } else {
          // Add to saved places
          await firestoreService.savePlace(user.uid, widget.place);
          ref
              .read(analyticsServiceProvider)
              .logButtonTap(
                buttonName: 'add_to_favorites',
                screenName: 'search_results',
                context: 'place_card',
              );
        }

        if (mounted) {
          setState(() {
            _isSaved = !_isSaved;
            _isLoading = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isSaved
                    ? AppLocalizations.of(context).placeSavedToFavorites
                    : AppLocalizations.of(context).placeRemovedFromFavorites,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).errorWithDetails(e.toString()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
    String placeType = widget.place.types.isNotEmpty
        ? widget.place.types.first.replaceAll('_', ' ').capitalize()
        : AppLocalizations.of(context).defaultPlaceType;

    // Extract location from formatted address (simplified)
    String location = widget.place.formattedAddress.split(',').length > 1
        ? widget.place.formattedAddress.split(',')[1].trim()
        : '';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          ref
              .read(analyticsServiceProvider)
              .logViewPlace(
                placeId: widget.place.placeId,
                placeName: widget.place.displayName,
                category: widget.place.category.name,
              );
          // Navigate to place detail using go_router with push
          context.push(
            '/place/${widget.place.placeId}?query=${Uri.encodeComponent(widget.query)}',
            extra: {'place': widget.place, 'heroTagIndex': widget.index},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            SizedBox(
              width: double.infinity,
              height: 200, // Fixed height for all images
              child: widget.place.photos.isNotEmpty
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Hero(
                              tag:
                                  'place-image-${widget.place.placeId}-${widget.index}',
                              child: CachedNetworkImage(
                                imageUrl: widget.place.photos.first.urlWithKey(
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
                        if (widget.place.photos.isNotEmpty)
                          PhotoAttribution(photo: widget.place.photos.first),
                        // Save button positioned in top-right corner
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading ? null : _toggleSaved,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        _isSaved
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _isSaved
                                            ? Colors.red
                                            : Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 40),
                        ),
                        // Save button positioned in top-right corner
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading ? null : _toggleSaved,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        _isSaved
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _isSaved
                                            ? Colors.red
                                            : Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                              ? widget.place.category.lightColor
                              : widget.place.category.darkColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.place.category.icon,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.place.category.name,
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
                    widget.place.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Generative Summary
                  if (widget.place.generativeSummary.isNotEmpty)
                    Text(
                      widget.place.generativeSummary,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Disclosure Text
                  if (widget.place.disclosureText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.place.disclosureText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Rating and reviews
                  if (widget.place.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).stars(widget.place.rating!.toString()),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (widget.place.userRatingCount != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context).reviews(
                              _formatRatingCount(widget.place.userRatingCount!),
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
