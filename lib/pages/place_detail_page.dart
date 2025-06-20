import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../l10n/app_localizations.dart';
import '../models/place.dart';
import '../config.dart';

class PlaceDetailPage extends StatefulWidget {
  const PlaceDetailPage({
    super.key, 
    required this.place, 
    this.heroTagIndex,
  });

  final Place place;
  final int? heroTagIndex;

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isSaved = false;
  bool _isAddedToItinerary = false;
  int _selectedNavIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                title: Text(AppLocalizations.of(context).imageCount('${currentIndex + 1}', '${widget.place.photos.length}')),
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
                  if (widget.place.photos[currentIndex].authorAttributions.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.black.withOpacity(0.5),
                        child: Text(
                          AppLocalizations.of(context).photoBy(widget.place.photos[currentIndex].authorAttributions.map((attr) => attr.displayName).join(", ")),
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

  void _sharePlaceInfo() {
    final url = widget.place.googleMapsUri;
    final message = AppLocalizations.of(context).shareMessage(
        widget.place.formattedAddress,
        widget.place.displayName,
        url);

    // Since we don't have share_plus package, we'll use url_launcher to open a share intent
    final uri = Uri.parse('mailto:?subject=${AppLocalizations.of(context).shareSubject}&body=$message');
    launchUrl(uri);
  }

  void _toggleSaved() {
    setState(() {
      _isSaved = !_isSaved;
    });
  }

  void _toggleAddToItinerary() {
    setState(() {
      _isAddedToItinerary = !_isAddedToItinerary;
    });
  }

  void _onNavItemTapped(int index) {
    if (index != _selectedNavIndex) {
      setState(() {
        _selectedNavIndex = index;
      });

      // Navigate to the appropriate page
      if (index == 0) {
        // Navigate to Home
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (index == 1) {
        // If we're already in a search flow, just go back one level
        Navigator.of(context).pop();
      }
      // Other navigation options can be added here
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding to account for navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = kBottomNavigationBarHeight + bottomPadding;

    return Scaffold(
      // Use a Column as the main layout
      body: Column(
        children: [
          // Main content with scrolling - takes all available space
          Expanded(
            child: CustomScrollView(
              slivers: [
                // App bar with back and share buttons
                SliverAppBar(
                  expandedHeight: 0,
                  floating: true,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _sharePlaceInfo,
                    ),
                  ],
                ),

                // Main content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image carousel
                      if (widget.place.photos.isNotEmpty) _buildImageCarousel(),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Place name
                            Text(
                              widget.place.displayName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Address
                            Text(
                              widget.place.formattedAddress,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),

                            const SizedBox(height: 8),

                            // Category and rating
                            Row(
                              children: [
                                if (widget.place.types.isNotEmpty)
                                  Text(
                                    widget.place.types.first.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                if (widget.place.types.isNotEmpty && widget.place.rating != null)
                                  const SizedBox(width: 8),
                                if (widget.place.rating != null) ...[
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(widget.place.rating!.toString()),
                                  if (widget.place.userRatingCount != null) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${widget.place.userRatingCount} reviews)',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ],
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Description
                            if (widget.place.generativeSummary.isNotEmpty) ...[
                              Text(
                                AppLocalizations.of(context).description,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.place.generativeSummary,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (widget.place.disclosureText.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  widget.place.disclosureText,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                            ],

                            // Additional information
                            Text(
                              AppLocalizations.of(context).additionalInfo,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Opening hours
                            if (widget.place.openingHours.isNotEmpty) ...[
                              _buildInfoItem(
                                icon: Icons.access_time,
                                title: widget.place.openingHours.first.contains('Open') 
                                    ? AppLocalizations.of(context).openNow 
                                    : AppLocalizations.of(context).closedNow,
                                subtitle: AppLocalizations.of(context).tapForHours,
                                onTap: () => _showOpeningHours(context),
                              ),
                              const Divider(),
                            ],

                            // Price range (mock data since it's not in the model)
                            _buildInfoItem(
                              icon: Icons.attach_money,
                              title: AppLocalizations.of(context).price,
                              subtitle: AppLocalizations.of(context).free,
                            ),
                            const Divider(),

                            // Contact
                            if (widget.place.websiteUri != null) ...[
                              _buildInfoItem(
                                icon: Icons.language,
                                title: AppLocalizations.of(context).website,
                                subtitle: AppLocalizations.of(context).visitWebsite,
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  final uri = Uri.parse(widget.place.websiteUri!);
                                  launchUrl(uri, mode: LaunchMode.externalApplication);
                                },
                              ),
                              const Divider(),
                            ],

                            // Google Maps
                            _buildInfoItem(
                              icon: Icons.map,
                              title: AppLocalizations.of(context).viewOnGoogleMaps,
                              subtitle: AppLocalizations.of(context).openInExternalApp,
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                final uri = Uri.parse(widget.place.googleMapsUri);
                                launchUrl(uri, mode: LaunchMode.externalApplication);
                              },
                            ),
                            const Divider(),

                            // Average visit time (mock data)
                            _buildInfoItem(
                              icon: Icons.timelapse,
                              title: AppLocalizations.of(context).averageVisitTime,
                              subtitle: AppLocalizations.of(context).oneToTwoHours,
                            ),

                            const SizedBox(height: 24),

                            // Map preview
                            Text(
                              AppLocalizations.of(context).location,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        Icons.map,
                                        size: 64,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                        color: Theme.of(context).colorScheme.primary,
                                        child: Text(
                                          AppLocalizations.of(context).openInMaps,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onPrimary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Add padding at the bottom to ensure content isn't hidden behind action buttons
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons in a fixed container at the bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleSaved,
                    icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
                    label: Text(AppLocalizations.of(context).save),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _toggleAddToItinerary,
                    icon: Icon(_isAddedToItinerary ? Icons.check : Icons.add),
                    label: Text(AppLocalizations.of(context).addToItinerary),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedNavIndex,
              type: BottomNavigationBarType.fixed,
              onTap: _onNavItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: AppLocalizations.of(context).navHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.search),
                  label: AppLocalizations.of(context).navExplore,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.map),
                  label: AppLocalizations.of(context).navMyTrips,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.group),
                  label: AppLocalizations.of(context).navGroups,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
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
                onTap: () => _openGallery(context, index),
                child: Stack(
                  children: [
                    Hero(
                      tag: widget.heroTagIndex != null 
                          ? 'place-image-${widget.place.placeId}-${widget.heroTagIndex}' 
                          : 'place-image-${widget.place.placeId}',
                      child: CachedNetworkImage(
                        imageUrl: widget.place.photos[index].urlWithKey(googlePlacesApiKey),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    ),
                    if (widget.place.photos[index].authorAttributions.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          color: Colors.black.withOpacity(0.5),
                          child: Text(
                            AppLocalizations.of(context).photoBy(widget.place.photos[index].authorAttributions.map((attr) => attr.displayName).join(", ")),
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

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showOpeningHours(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).openingHours,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...widget.place.openingHours.map((hour) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(hour),
              )).toList(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
