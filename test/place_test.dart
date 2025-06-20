import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/models/place_category.dart';
import 'package:travel_genie/models/location.dart';

void main() {
  group('Place', () {
    test('constructor assigns correct category based on types', () {
      // Test case 1: Place with types that match a single category (Transportation)
      final transportationPlace = Place(
        placeId: '1',
        displayName: 'Airport',
        displayNameLanguageCode: 'en',
        formattedAddress: '123 Airport Road',
        googleMapsUri: 'https://maps.google.com/?q=1',
        types: const ['airport', 'establishment'],
        location: const Location(lat: 0, lng: 0),
      );
      
      expect(transportationPlace.category, PlaceCategories.transportation);
      
      // Test case 2: Place with types that match multiple categories, but more in Food & Drink
      final foodPlace = Place(
        placeId: '2',
        displayName: 'Restaurant & Hotel',
        displayNameLanguageCode: 'en',
        formattedAddress: '456 Food Street',
        googleMapsUri: 'https://maps.google.com/?q=2',
        types: const ['restaurant', 'cafe', 'lodging', 'establishment'],
        location: const Location(lat: 0, lng: 0),
      );
      
      // Should be Food & Drink because it has 2 matches (restaurant, cafe) vs 1 for Accommodation (lodging)
      expect(foodPlace.category, PlaceCategories.foodAndDrink);
      
      // Test case 3: Place with equal matches in multiple categories (tie-breaking)
      final tiePlace = Place(
        placeId: '3',
        displayName: 'Hotel with Restaurant',
        displayNameLanguageCode: 'en',
        formattedAddress: '789 Tie Street',
        googleMapsUri: 'https://maps.google.com/?q=3',
        types: const ['lodging', 'restaurant', 'establishment'],
        location: const Location(lat: 0, lng: 0),
      );
      
      // Should be the first category with a match in the PlaceCategories.all list
      // Since accommodation comes before foodAndDrink in the list, it should be accommodation
      expect(tiePlace.category, PlaceCategories.accommodation);
      
      // Test case 4: Place with no matching types
      final noMatchPlace = Place(
        placeId: '4',
        displayName: 'Unknown Place',
        displayNameLanguageCode: 'en',
        formattedAddress: '101 Unknown Street',
        googleMapsUri: 'https://maps.google.com/?q=4',
        types: const ['unknown_type', 'another_unknown_type'],
        location: const Location(lat: 0, lng: 0),
      );
      
      // Should default to the first category
      expect(noMatchPlace.category, PlaceCategories.all.first);
      
      // Test case 5: Place with no types
      final noTypesPlace = Place(
        placeId: '5',
        displayName: 'No Types Place',
        displayNameLanguageCode: 'en',
        formattedAddress: '202 No Types Street',
        googleMapsUri: 'https://maps.google.com/?q=5',
        types: const [],
        location: const Location(lat: 0, lng: 0),
      );
      
      // Should default to the first category
      expect(noTypesPlace.category, PlaceCategories.all.first);
    });
    
    test('fromJson assigns correct category based on types', () {
      // Test that fromJson correctly assigns the category based on types
      final json = {
        'place_id': '6',
        'display_name': {
          'text': 'JSON Restaurant',
          'language_code': 'en'
        },
        'formatted_address': '303 JSON Street',
        'google_maps_uri': 'https://maps.google.com/?q=6',
        'types': ['restaurant', 'cafe', 'establishment'],
        'location': {
          'lat': 0.0,
          'lng': 0.0
        }
      };
      
      final place = Place.fromJson(json);
      
      // Should be Food & Drink because of restaurant and cafe types
      expect(place.category, PlaceCategories.foodAndDrink);
    });
  });
}