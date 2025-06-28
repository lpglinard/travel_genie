/// Models for drag and drop functionality in trip itinerary
import 'place.dart';

/// Data class that represents a place being dragged in the itinerary interface.
///
/// This class encapsulates the information needed during drag-and-drop operations,
/// including the place being moved and its source location.
class DraggedPlaceData {
  /// The place being dragged
  final Place place;

  /// The ID of the day from which the place is being dragged.
  /// This is null if the place is being dragged from the saved places bin.
  final String? fromDayId;

  /// Creates a new [DraggedPlaceData] instance.
  ///
  /// [place] is required and represents the place being dragged.
  /// [fromDayId] is optional and represents the source day ID.
  const DraggedPlaceData({required this.place, this.fromDayId});

  /// Returns true if this place is being dragged from the saved places bin
  bool get isFromSavedPlaces => fromDayId == null;

  /// Returns true if this place is being dragged from a specific day
  bool get isFromDay => fromDayId != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraggedPlaceData &&
          runtimeType == other.runtimeType &&
          place == other.place &&
          fromDayId == other.fromDayId;

  @override
  int get hashCode => place.hashCode ^ fromDayId.hashCode;

  @override
  String toString() =>
      'DraggedPlaceData(place: ${place.displayName}, fromDayId: $fromDayId)';
}
