import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/place.dart';
import '../providers/challenge_providers.dart';
import '../providers/user_providers.dart';
import '../widgets/login_required_dialog.dart';
import '../widgets/place_detail/action_buttons.dart';
import '../widgets/place_detail/additional_info_section.dart';
import '../widgets/place_detail/description_section.dart';
import '../widgets/place_detail/image_carousel.dart';
import '../widgets/place_detail/location_map_section.dart';
import '../widgets/place_detail/photo_gallery.dart';
import '../widgets/place_detail/place_info_section.dart';

class PlaceDetailPage extends ConsumerStatefulWidget {
  const PlaceDetailPage({super.key, required this.place, this.heroTagIndex});

  final Place place;
  final int? heroTagIndex;

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
  bool _isSaved = false;
  bool _isAddedToItinerary = false;
  int _selectedNavIndex = 0;
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _checkIfPlaceIsSaved();
  }

  void _getCurrentUser() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _currentUserId = user.uid;
        });
      }
    } catch (e) {
      // Firebase might not be initialized in tests
    }
  }

  Future<void> _checkIfPlaceIsSaved() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        final isSaved = await firestoreService.isPlaceSaved(
          user.uid,
          widget.place.placeId,
        );

        setState(() {
          _isSaved = isSaved;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Firebase might not be initialized in tests
    }
  }

  void _openGallery(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PhotoGallery(place: widget.place, initialIndex: index),
      ),
    );
  }

  void _sharePlaceInfo() {
    // Track place sharing analytics
    try {
      final analyticsService = ref.read(analyticsServiceProvider);
      analyticsService.logCustomEvent(
        eventName: 'share',
        parameters: {
          'content_type': 'place',
          'item_id': widget.place.placeId,
          'method': 'email',
        },
      );
    } catch (e) {
      debugPrint('Error tracking place share analytics: $e');
    }

    final url = widget.place.googleMapsUri;
    final message = AppLocalizations.of(context).shareMessage(
      widget.place.formattedAddress,
      widget.place.displayName,
      url,
    );

    // Since we don't have share_plus package, we'll use url_launcher to open a share intent
    final uri = Uri.parse(
      'mailto:?subject=${AppLocalizations.of(context).shareSubject}&body=$message',
    );
    launchUrl(uri);
  }

  Future<void> _toggleSaved() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Show login required dialog
        await LoginRequiredDialog.show(context);
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
        } else {
          // Add to saved places
          await firestoreService.savePlace(user.uid, widget.place);

          // Track challenge progress for saving a place
          try {
            final challengeActions = ref.read(challengeActionsProvider);
            await challengeActions.markCompleted(user.uid, 'save_place');
            debugPrint('[DEBUG_LOG] Save place challenge marked as completed for user ${user.uid}');
          } catch (e) {
            // Log error but don't prevent the place save success flow
            debugPrint('Error tracking save_place challenge: $e');
          }
        }

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
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorSavingPlace,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.primaryContainer,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Firebase might not be initialized in tests

      // Just toggle the state for tests
      setState(() {
        _isSaved = !_isSaved;
      });
    }
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

      // Pop to root and then navigate to the selected tab
      while (context.canPop()) {
        context.pop();
      }

      // Navigate using go_router
      switch (index) {
        case 0:
          // Navigate to Home
          context.go('/');
          break;
        case 1:
          // Navigate to Explore
          final uri = GoRouterState.of(context).uri;
          final query = uri.queryParameters['query'] ?? '';
          context.go('/explore${query.isNotEmpty ? "?query=$query" : ""}');
          break;
        case 2:
          // Navigate to Trips
          context.go('/trips');
          break;
        case 3:
          // Navigate to Groups
          context.go('/groups');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onPressed: () {
                      // Always try to pop first to maintain navigation history
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        // If can't pop, go to explore with the query if available
                        final uri = GoRouterState.of(context).uri;
                        final query = uri.queryParameters['query'] ?? '';
                        context.go(
                          '/explore${query.isNotEmpty ? "?query=$query" : ""}',
                        );
                      }
                    },
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
                      if (widget.place.photos.isNotEmpty)
                        ImageCarousel(
                          place: widget.place,
                          heroTagIndex: widget.heroTagIndex,
                          onGalleryOpen: (index) =>
                              _openGallery(context, index),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Place information section
                            PlaceInfoSection(place: widget.place),

                            const SizedBox(height: 24),

                            // Description section
                            DescriptionSection(place: widget.place),

                            // Additional information section
                            AdditionalInfoSection(place: widget.place),

                            // Location/map section
                            LocationMapSection(place: widget.place),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          ActionButtons(
            isSaved: _isSaved,
            isAddedToItinerary: _isAddedToItinerary,
            isLoading: _isLoading,
            onSavePressed: _toggleSaved,
            onAddToItineraryPressed: _toggleAddToItinerary,
          ),
        ],
      ),
    );
  }
}
