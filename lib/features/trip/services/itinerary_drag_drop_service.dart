import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/features/place/models/drag_drop_models.dart';
import 'package:travel_genie/features/place/models/place.dart';

import '../providers/trip_providers.dart';

/// Service that handles the business logic for drag-and-drop operations in the trip itinerary.
///
/// This service encapsulates all the complex logic for moving places between days,
/// reordering places within days, and adding places from the saved places bin.
/// It provides a clean separation between UI components and business logic.
class ItineraryDragDropService {
  /// Reference to the Riverpod container for accessing providers
  final ProviderRef<ItineraryDragDropService> _ref;

  /// The ID of the current trip
  final String _tripId;

  /// Creates a new [ItineraryDragDropService].
  ///
  /// [ref] is the Riverpod reference for accessing providers.
  /// [tripId] is the ID of the trip being managed.
  const ItineraryDragDropService(this._ref, this._tripId);

  /// Handles a place being dropped on a specific day at a specific position.
  ///
  /// This method determines the appropriate action based on the source and destination:
  /// - If moving between different days: removes from source and adds to destination
  /// - If reordering within the same day: reorders the places
  /// - If adding from saved places: adds to the destination day
  ///
  /// [data] contains the place being moved and its source information.
  /// [targetDayId] is the ID of the day where the place is being dropped.
  /// [insertIndex] is the position where the place should be inserted.
  /// [currentPlaces] is the current list of places in the target day.
  Future<void> handlePlaceDrop({
    required DraggedPlaceData data,
    required String targetDayId,
    required int insertIndex,
    required List<Place> currentPlaces,
  }) async {
    final tripService = _ref.read(tripServiceProvider);

    try {
      // Handle different drop scenarios
      if (data.isFromSavedPlaces) {
        await _handleDropFromSavedPlaces(
          tripService: tripService,
          place: data.place,
          targetDayId: targetDayId,
          insertIndex: insertIndex,
          currentPlaces: currentPlaces,
        );
      } else if (data.fromDayId != targetDayId) {
        await _handleDropBetweenDays(
          tripService: tripService,
          data: data,
          targetDayId: targetDayId,
          insertIndex: insertIndex,
          currentPlaces: currentPlaces,
        );
      } else {
        await _handleReorderWithinDay(
          tripService: tripService,
          data: data,
          targetDayId: targetDayId,
          insertIndex: insertIndex,
          currentPlaces: currentPlaces,
        );
      }
    } catch (e) {
      // Log error and potentially show user feedback
      throw ItineraryDragDropException('Failed to move place: $e');
    }
  }

  /// Handles dropping a place from the saved places bin to a day
  Future<void> _handleDropFromSavedPlaces({
    required dynamic tripService,
    required Place place,
    required String targetDayId,
    required int insertIndex,
    required List<Place> currentPlaces,
  }) async {
    // Only add if the place is not already in the day
    if (!currentPlaces.contains(place)) {
      await tripService.addPlaceToDay(
        tripId: _tripId,
        dayId: targetDayId,
        place: place,
        position: insertIndex,
      );
    }
  }

  /// Handles dropping a place from one day to another day
  Future<void> _handleDropBetweenDays({
    required dynamic tripService,
    required DraggedPlaceData data,
    required String targetDayId,
    required int insertIndex,
    required List<Place> currentPlaces,
  }) async {
    // Remove from source day first
    await tripService.removePlaceFromDay(
      tripId: _tripId,
      dayId: data.fromDayId!,
      place: data.place,
    );

    // Add to target day if not already present
    if (!currentPlaces.contains(data.place)) {
      await tripService.addPlaceToDay(
        tripId: _tripId,
        dayId: targetDayId,
        place: data.place,
        position: insertIndex,
      );
    }
  }

  /// Handles reordering a place within the same day
  Future<void> _handleReorderWithinDay({
    required dynamic tripService,
    required DraggedPlaceData data,
    required String targetDayId,
    required int insertIndex,
    required List<Place> currentPlaces,
  }) async {
    final oldIndex = currentPlaces.indexWhere((p) => p == data.place);

    // Only reorder if the position actually changed
    if (oldIndex != -1 && oldIndex != insertIndex) {
      await tripService.reorderPlacesWithinDay(
        tripId: _tripId,
        dayId: targetDayId,
        oldIndex: oldIndex,
        newIndex: insertIndex,
      );
    }
  }

  /// Validates that a drop operation is allowed
  ///
  /// This method can be extended to add business rules for drag-and-drop operations,
  /// such as preventing certain types of places from being added to specific days.
  bool canAcceptDrop({
    required DraggedPlaceData data,
    required String targetDayId,
    required List<Place> currentPlaces,
  }) {
    // Basic validation: don't allow dropping the same place twice in the same day
    if (data.fromDayId != targetDayId && currentPlaces.contains(data.place)) {
      return false;
    }

    // Add more business rules here as needed
    return true;
  }
}

/// Exception thrown when a drag-and-drop operation fails
class ItineraryDragDropException implements Exception {
  /// The error message
  final String message;

  /// Creates a new [ItineraryDragDropException]
  const ItineraryDragDropException(this.message);

  @override
  String toString() => 'ItineraryDragDropException: $message';
}

/// Provider for the ItineraryDragDropService
///
/// This provider creates a service instance for a specific trip.
/// Usage: `ref.read(itineraryDragDropServiceProvider(tripId))`
final itineraryDragDropServiceProvider =
    Provider.family<ItineraryDragDropService, String>(
      (ref, tripId) => ItineraryDragDropService(ref, tripId),
    );
