# Place Categories

This document describes the implementation of place categories in the Travel Genie app.

## Overview

Each place in the app has a list of types (e.g., "restaurant", "airport", etc.). The new category feature groups these types into meaningful categories to help users better understand and filter places.

A place can belong to multiple categories, and each category can contain multiple place types.

## Implementation

### Models

The implementation consists of two main classes:

1. `PlaceCategory`: Represents a category of places with properties for:
   - ID
   - Name
   - List of place types
   - Icon
   - Light and dark colors
   - Description

2. `PlaceCategories`: A utility class with:
   - Static instances of all 9 categories
   - Methods to get categories for a place
   - Method to get a category by ID

### Categories

The following 9 categories have been implemented:

1. **Transportation**
   - Types: airport, bus_station, train_station, subway_station, transit_station, light_rail_station, taxi_stand, parking, car_rental, gas_station, rv_park
   - Icon: Icons.directions_transit
   - Colors: Light (0xFF2196F3), Dark (0xFF1976D2)
   - Description: "Airports, stations, and services to get you moving between destinations."

2. **Accommodation**
   - Types: lodging, campground
   - Icon: Icons.hotel
   - Colors: Light (0xFF3F51B5), Dark (0xFF303F9F)
   - Description: "Places to stay – hotels, inns, or campsites along your journey."

3. **Food & Drink**
   - Types: restaurant, cafe, bar, bakery, meal_delivery, meal_takeaway, liquor_store
   - Icon: Icons.restaurant_menu
   - Colors: Light (0xFFFF9800), Dark (0xFFF57C00)
   - Description: "Eat, drink and enjoy local flavors wherever you go."

4. **Attractions & Culture**
   - Types: tourist_attraction, museum, art_gallery, zoo, aquarium, park, stadium, amusement_park, movie_theater
   - Icon: Icons.camera_alt
   - Colors: Light (0xFFE91E63), Dark (0xFFC2185B)
   - Description: "Explore must-see sights and cultural gems of your destination."

5. **Shopping & Local Goods**
   - Types: shopping_mall, store, department_store, clothing_store, shoe_store, supermarket, convenience_store, electronics_store, book_store, furniture_store, hardware_store, jewelry_store, home_goods_store, bicycle_store, pet_store, florist, liquor_store
   - Icon: Icons.shopping_cart
   - Colors: Light (0xFF4CAF50), Dark (0xFF2E7D32)
   - Description: "Places to shop, find essentials, or bring home souvenirs."

6. **Health & Wellness**
   - Types: hospital, doctor, dentist, pharmacy, drugstore, gym, spa, physiotherapist, veterinary_care, beauty_salon, hair_care
   - Icon: Icons.health_and_safety
   - Colors: Light (0xFF9C27B0), Dark (0xFF7B1FA2)
   - Description: "Medical help and wellness services during your trip."

7. **Navigation & Assistance**
   - Types: travel_agency, atm, bank, police, post_office, embassy, local_government_office, city_hall, courthouse, insurance_agency
   - Icon: Icons.support_agent
   - Colors: Light (0xFF607D8B), Dark (0xFF455A64)
   - Description: "Essential services and help when navigating unfamiliar places."

8. **Spiritual & Religious Sites**
   - Types: church, hindu_temple, mosque, synagogue, cemetery
   - Icon: Icons.temple_buddhist
   - Colors: Light (0xFFFFC107), Dark (0xFFFFA000)
   - Description: "Places of worship, reflection, and local spirituality."

9. **Local Services**
   - Types: car_dealer, car_repair, car_wash, electrician, plumber, painter, laundry, locksmith, funeral_home, roofing_contractor, storage, moving_company, accounting, lawyer, real_estate_agency, school, university, primary_school, secondary_school, library
   - Icon: Icons.build
   - Colors: Light (0xFF795548), Dark (0xFF5D4037)
   - Description: "Useful infrastructure and support services, more relevant for longer stays."

## Usage

### Getting Categories for a Place

```dart
// Get a place from somewhere
Place place = ...;

// Get all categories that this place belongs to
List<PlaceCategory> categories = PlaceCategories.getCategoriesForPlace(place);

// Use the categories
for (final category in categories) {
  print('${place.displayName} belongs to ${category.name}');
  // Use category.icon, category.lightColor, etc.
}
```

### Getting a Category by ID

```dart
// Get a category by its ID
PlaceCategory? category = PlaceCategories.getCategoryById(1);
if (category != null) {
  print('Category: ${category.name}');
}
```

### Checking if a Place Belongs to a Category

```dart
// Check if a place belongs to a specific category
Place place = ...;
bool isTransportation = PlaceCategories.transportation.containsPlace(place);
if (isTransportation) {
  print('${place.displayName} is a transportation place');
}
```

## UI Integration Examples

### Displaying Category Icons and Colors

```dart
// In a widget
Widget buildCategoryIcon(PlaceCategory category) {
  return Icon(
    category.icon,
    color: Theme.of(context).brightness == Brightness.light
        ? category.lightColor
        : category.darkColor,
  );
}
```

### Filtering Places by Category

```dart
// Get all places
List<Place> allPlaces = ...;

// Filter places by a specific category
List<Place> transportationPlaces = allPlaces
    .where((place) => PlaceCategories.transportation.containsPlace(place))
    .toList();
```

### Grouping Places by Category

```dart
// Get all places
List<Place> allPlaces = ...;

// Group places by category
Map<PlaceCategory, List<Place>> placesByCategory = {};

for (final category in PlaceCategories.all) {
  placesByCategory[category] = allPlaces
      .where((place) => category.containsPlace(place))
      .toList();
}

// Use the grouped places
for (final entry in placesByCategory.entries) {
  print('Category: ${entry.key.name}, Places: ${entry.value.length}');
}
```

## Next Steps

The category structure can be used to:

1. Filter places by category in search results
2. Display category icons and colors in the UI
3. Group places by category in lists or maps
4. Provide category-specific recommendations