import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/models/place_category.dart';
import 'package:travel_genie/models/place_categories.dart';
import 'package:travel_genie/models/location.dart';

void main() {
  group('PlaceCategory', () {
    test('all categories are correctly defined', () {
      // Verify that all 10 categories are defined
      expect(PlaceCategories.all.length, 10);

      // Verify that each category has the correct properties
      final transportation = PlaceCategories.transportation;
      expect(transportation.id, 1);
      expect(transportation.name, 'Transportation');
      expect(transportation.types.length, 11);
      expect(transportation.types.contains('airport'), true);
      expect(transportation.icon, Icons.directions_transit);
      expect(transportation.lightColor, const Color(0xFF2196F3));
      expect(transportation.darkColor, const Color(0xFF1976D2));
      expect(transportation.description, 'Airports, stations, and services to get you moving between destinations.');

      // Verify a few more categories
      final accommodation = PlaceCategories.accommodation;
      expect(accommodation.id, 2);
      expect(accommodation.name, 'Accommodation');
      expect(accommodation.types.length, 2);
      expect(accommodation.types.contains('lodging'), true);

      final foodAndDrink = PlaceCategories.foodAndDrink;
      expect(foodAndDrink.id, 3);
      expect(foodAndDrink.name, 'Food & Drink');
      expect(foodAndDrink.types.length, 7);
      expect(foodAndDrink.types.contains('restaurant'), true);
    });

    test('containsPlace correctly identifies if a place belongs to a category', () {
      // Create test places
      final airportPlace = Place(
        placeId: '1',
        displayName: 'Test Airport',
        displayNameLanguageCode: 'en',
        formattedAddress: '123 Airport Road',
        googleMapsUri: 'https://maps.google.com/?q=1',
        types: const ['airport', 'establishment'],
        location: const Location(lat: 0, lng: 0),
      );

      final hotelPlace = Place(
        placeId: '2',
        displayName: 'Test Hotel',
        displayNameLanguageCode: 'en',
        formattedAddress: '456 Hotel Street',
        googleMapsUri: 'https://maps.google.com/?q=2',
        types: const ['lodging', 'establishment'],
        location: const Location(lat: 0, lng: 0),
      );

      final restaurantPlace = Place(
        placeId: '3',
        displayName: 'Test Restaurant',
        displayNameLanguageCode: 'en',
        formattedAddress: '789 Restaurant Avenue',
        googleMapsUri: 'https://maps.google.com/?q=3',
        types: const ['restaurant', 'food', 'establishment'],
        location: const Location(lat: 0, lng: 0),
      );

      // Test containsPlaceTypes method
      expect(PlaceCategories.transportation.containsPlaceTypes(airportPlace.types), true);
      expect(PlaceCategories.transportation.containsPlaceTypes(hotelPlace.types), false);
      expect(PlaceCategories.transportation.containsPlaceTypes(restaurantPlace.types), false);

      expect(PlaceCategories.accommodation.containsPlaceTypes(airportPlace.types), false);
      expect(PlaceCategories.accommodation.containsPlaceTypes(hotelPlace.types), true);
      expect(PlaceCategories.accommodation.containsPlaceTypes(restaurantPlace.types), false);

      expect(PlaceCategories.foodAndDrink.containsPlaceTypes(airportPlace.types), false);
      expect(PlaceCategories.foodAndDrink.containsPlaceTypes(hotelPlace.types), false);
      expect(PlaceCategories.foodAndDrink.containsPlaceTypes(restaurantPlace.types), true);
    });

    test('getCategoriesForPlace returns correct categories', () {
      // Create a place that belongs to multiple categories
      final multiCategoryPlace = Place(
        placeId: '4',
        displayName: 'Multi-Category Place',
        displayNameLanguageCode: 'en',
        formattedAddress: '101 Multi Street',
        googleMapsUri: 'https://maps.google.com/?q=4',
        types: const ['restaurant', 'lodging', 'establishment'],
        location: const Location(lat: 0, lng: 0),
      );

      // Test getCategoriesForTypes method
      final categories = PlaceCategories.getCategoriesForTypes(multiCategoryPlace.types);
      expect(categories.length, 2);
      expect(categories.any((c) => c.id == PlaceCategories.accommodation.id), true);
      expect(categories.any((c) => c.id == PlaceCategories.foodAndDrink.id), true);
      expect(categories.any((c) => c.id == PlaceCategories.transportation.id), false);
    });

    test('getCategoryById returns correct category', () {
      // Test getCategoryById method
      final category1 = PlaceCategories.getCategoryById(1);
      expect(category1, PlaceCategories.transportation);

      final category2 = PlaceCategories.getCategoryById(2);
      expect(category2, PlaceCategories.accommodation);

      final category3 = PlaceCategories.getCategoryById(3);
      expect(category3, PlaceCategories.foodAndDrink);

      final nonExistentCategory = PlaceCategories.getCategoryById(100);
      expect(nonExistentCategory, null);
    });
  });
}
