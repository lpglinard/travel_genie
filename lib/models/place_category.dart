import 'package:flutter/material.dart';
import 'place.dart';

/// Represents a category of places.
/// Each category contains a list of place types that belong to it.
class PlaceCategory {
  const PlaceCategory({
    required this.id,
    required this.name,
    required this.types,
    required this.icon,
    required this.lightColor,
    required this.darkColor,
    required this.description,
  });

  /// Unique identifier for the category
  final int id;

  /// Display name of the category
  final String name;

  /// List of place types that belong to this category
  final List<String> types;

  /// Icon representing the category
  final IconData icon;

  /// Color for light theme
  final Color lightColor;

  /// Color for dark theme
  final Color darkColor;

  /// Description of the category
  final String description;

  /// Checks if a place belongs to this category
  bool containsPlace(Place place) {
    return place.types.any((type) => types.contains(type));
  }
}

/// Utility class for working with place categories
class PlaceCategories {

  /// Transportation category
  static const PlaceCategory transportation = PlaceCategory(
    id: 1,
    name: 'Transportation',
    types: [
      'airport', 'bus_station', 'train_station', 'subway_station', 
      'transit_station', 'light_rail_station', 'taxi_stand', 
      'parking', 'car_rental', 'gas_station', 'rv_park'
    ],
    icon: Icons.directions_transit,
    lightColor: Color(0xFF2196F3),
    darkColor: Color(0xFF1976D2),
    description: 'Airports, stations, and services to get you moving between destinations.',
  );

  /// Accommodation category
  static const PlaceCategory accommodation = PlaceCategory(
    id: 2,
    name: 'Accommodation',
    types: ['lodging', 'campground'],
    icon: Icons.hotel,
    lightColor: Color(0xFF3F51B5),
    darkColor: Color(0xFF303F9F),
    description: 'Places to stay – hotels, inns, or campsites along your journey.',
  );

  /// Food & Drink category
  static const PlaceCategory foodAndDrink = PlaceCategory(
    id: 3,
    name: 'Food & Drink',
    types: [
      'restaurant', 'cafe', 'bar', 'bakery', 
      'meal_delivery', 'meal_takeaway', 'liquor_store'
    ],
    icon: Icons.restaurant_menu,
    lightColor: Color(0xFFFF9800),
    darkColor: Color(0xFFF57C00),
    description: 'Eat, drink and enjoy local flavors wherever you go.',
  );

  /// Attractions & Culture category
  static const PlaceCategory attractionsAndCulture = PlaceCategory(
    id: 4,
    name: 'Attractions & Culture',
    types: [
      'tourist_attraction', 'museum', 'art_gallery', 'zoo', 
      'aquarium', 'park', 'stadium', 'amusement_park', 'movie_theater'
    ],
    icon: Icons.camera_alt,
    lightColor: Color(0xFFE91E63),
    darkColor: Color(0xFFC2185B),
    description: 'Explore must-see sights and cultural gems of your destination.',
  );

  /// Shopping & Local Goods category
  static const PlaceCategory shoppingAndLocalGoods = PlaceCategory(
    id: 5,
    name: 'Shopping & Local Goods',
    types: [
      'shopping_mall', 'store', 'department_store', 'clothing_store', 
      'shoe_store', 'supermarket', 'convenience_store', 'electronics_store', 
      'book_store', 'furniture_store', 'hardware_store', 'jewelry_store', 
      'home_goods_store', 'bicycle_store', 'pet_store', 'florist', 'liquor_store'
    ],
    icon: Icons.shopping_cart,
    lightColor: Color(0xFF4CAF50),
    darkColor: Color(0xFF2E7D32),
    description: 'Places to shop, find essentials, or bring home souvenirs.',
  );

  /// Health & Wellness category
  static const PlaceCategory healthAndWellness = PlaceCategory(
    id: 6,
    name: 'Health & Wellness',
    types: [
      'hospital', 'doctor', 'dentist', 'pharmacy', 'drugstore', 
      'gym', 'spa', 'physiotherapist', 'veterinary_care', 
      'beauty_salon', 'hair_care'
    ],
    icon: Icons.health_and_safety,
    lightColor: Color(0xFF9C27B0),
    darkColor: Color(0xFF7B1FA2),
    description: 'Medical help and wellness services during your trip.',
  );

  /// Navigation & Assistance category
  static const PlaceCategory navigationAndAssistance = PlaceCategory(
    id: 7,
    name: 'Navigation & Assistance',
    types: [
      'travel_agency', 'atm', 'bank', 'police', 'post_office', 
      'embassy', 'local_government_office', 'city_hall', 
      'courthouse', 'insurance_agency'
    ],
    icon: Icons.support_agent,
    lightColor: Color(0xFF607D8B),
    darkColor: Color(0xFF455A64),
    description: 'Essential services and help when navigating unfamiliar places.',
  );

  /// Spiritual & Religious Sites category
  static const PlaceCategory spiritualAndReligiousSites = PlaceCategory(
    id: 8,
    name: 'Spiritual & Religious Sites',
    types: [
      'church', 'hindu_temple', 'mosque', 'synagogue', 'cemetery'
    ],
    icon: Icons.temple_buddhist,
    lightColor: Color(0xFFFFC107),
    darkColor: Color(0xFFFFA000),
    description: 'Places of worship, reflection, and local spirituality.',
  );

  /// Local Services category
  static const PlaceCategory localServices = PlaceCategory(
    id: 9,
    name: 'Local Services',
    types: [
      'car_dealer', 'car_repair', 'car_wash', 'electrician', 'plumber', 
      'painter', 'laundry', 'locksmith', 'funeral_home', 'roofing_contractor', 
      'storage', 'moving_company', 'accounting', 'lawyer', 'real_estate_agency', 
      'school', 'university', 'primary_school', 'secondary_school', 'library'
    ],
    icon: Icons.build,
    lightColor: Color(0xFF795548),
    darkColor: Color(0xFF5D4037),
    description: 'Useful infrastructure and support services, more relevant for longer stays.',
  );

  /// Miscellaneous category for places that don't fit into other categories
  static const PlaceCategory miscellaneous = PlaceCategory(
    id: 10,
    name: 'Miscellaneous',
    types: [], // Empty list since this is for places that don't match other categories
    icon: Icons.more_horiz,
    lightColor: Color(0xFF9E9E9E), // Gray color
    darkColor: Color(0xFF616161), // Dark gray
    description: 'Other places that don\'t fit into specific categories.',
  );

  /// All available categories
  static final List<PlaceCategory> all = [
    transportation,
    accommodation,
    foodAndDrink,
    attractionsAndCulture,
    shoppingAndLocalGoods,
    healthAndWellness,
    navigationAndAssistance,
    spiritualAndReligiousSites,
    localServices,
    miscellaneous,
  ];

  /// Get all categories that a place belongs to
  static List<PlaceCategory> getCategoriesForPlace(Place place) {
    return all.where((PlaceCategory category) => category.containsPlace(place)).toList();
  }

  /// Get all categories that match any of the given types
  static List<PlaceCategory> getCategoriesForTypes(List<String> types) {
    return all.where((category) => 
      types.any((type) => category.types.contains(type))
    ).toList();
  }

  /// Get a category by its ID
  static PlaceCategory? getCategoryById(int id) {
    try {
      return all.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
