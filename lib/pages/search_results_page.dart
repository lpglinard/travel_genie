import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place.dart';
import '../providers/search_results_provider.dart';
import '../l10n/app_localizations.dart';
import '../config.dart';
import 'place_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key, required this.query});

  final String query;

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';
  List<String> _getCategories(BuildContext context) {
    return [
      AppLocalizations.of(context).categoryAll,
      AppLocalizations.of(context).categoryAttractions,
      AppLocalizations.of(context).categoryRestaurants,
      AppLocalizations.of(context).categoryHotels
    ];
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    Future.microtask(() {
      ref.read(searchResultsProvider.notifier).search(widget.query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    // In a real implementation, you would filter the results based on the category
    // For now, we'll just update the UI to show the selected category
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize selected category with localized value
    if (_selectedCategory == 'All') {
      _selectedCategory = AppLocalizations.of(context).categoryAll;
    }
  }

  // Add a variable to track the selected navigation index
  int _selectedNavIndex = 1; // Default to Explore tab

  void _onNavItemTapped(int index) {
    if (index != _selectedNavIndex) {
      setState(() {
        _selectedNavIndex = index;
      });

      // Navigate to the appropriate page
      if (index == 0) {
        // Navigate to Home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      // Other navigation options can be added here
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    ref.read(searchResultsProvider.notifier).search(value);
                  }
                },
              ),
            ),

            // Category filters
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _getCategories(context).length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final category = _getCategories(context)[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _filterByCategory(category),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                        foregroundColor: isSelected ? Colors.white : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: isSelected ? 2 : 0,
                      ),
                      child: Text(category),
                    ),
                  );
                },
              ),
            ),

            // Results list
            Expanded(
              child: results.when(
                data: (list) {
                  if (list.isEmpty) {
                    return Center(child: Text(AppLocalizations.of(context).noResults));
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      final place = list[index];

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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlaceDetailPage(
                                  place: place,
                                  heroTagIndex: index,
                                ),
                              ),
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
                                                imageUrl: place.photos.first
                                                    .urlWithKey(googlePlacesApiKey),
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
                                                  child: const Icon(Icons.broken_image, size: 40),
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
                                                AppLocalizations.of(context).photoBy(place.photos.first.authorAttributions.map((attr) => attr.displayName).join(", ")),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                                textAlign: TextAlign.end,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
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
                                    // Type and location
                                    Text(
                                      '$placeType${AppLocalizations.of(context).locationSeparator}$location',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
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
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    // Disclosure Text
                                    if (place.disclosureText.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        place.disclosureText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
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
                                            AppLocalizations.of(context).stars(place.rating!.toString()),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          if (place.userRatingCount != null) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocalizations.of(context).reviews(_formatRatingCount(place.userRatingCount!)),
                                              style: TextStyle(color: Colors.grey.shade600),
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
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }

  // Helper method to format rating count (e.g., 1200 -> 1.2k)
  String _formatRatingCount(int count) {
    if (count >= 1000) {
      final double countInK = count / 1000;
      return '${countInK.toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
