import 'package:flutter/material.dart';

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

  /// Checks if a place with the given types belongs to this category
  bool containsPlaceTypes(List<String> placeTypes) {
    return placeTypes.any((type) => types.contains(type));
  }

  /// Checks if a place belongs to this category
  /// This is a convenience method that calls containsPlaceTypes
  bool containsPlace(dynamic place) {
    if (place == null) return false;

    // If place has a types property, use it
    if (place is Map && place['types'] is List) {
      return containsPlaceTypes(List<String>.from(place['types']));
    }

    // If place has a types getter, use it
    try {
      final placeTypes = place.types;
      if (placeTypes is List) {
        return containsPlaceTypes(List<String>.from(placeTypes));
      }
    } catch (_) {}

    return false;
  }
}