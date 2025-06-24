import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/place.dart';
import '../../models/drag_drop_models.dart';

/// A widget that displays saved places in a draggable format.
/// 
/// This widget shows a collection of saved places as draggable chips
/// that can be moved to itinerary days. Each place is displayed with
/// its icon, name, and address in a visually appealing card format.
class SavedPlacesBin extends StatelessWidget {
  /// The list of saved places to display
  final List<Place> places;

  /// Creates a new [SavedPlacesBin].
  /// 
  /// [places] is the list of saved places to display as draggable items.
  const SavedPlacesBin({
    super.key,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: places.map((place) => _buildDraggablePlace(context, place)).toList(),
      ),
    );
  }

  /// Builds a single draggable place item
  Widget _buildDraggablePlace(BuildContext context, Place place) {
    return LongPressDraggable<DraggedPlaceData>(
      data: DraggedPlaceData(place: place, fromDayId: null),
      feedback: _buildDragFeedback(context, place),
      child: _buildPlaceChip(context, place),
    );
  }

  /// Builds the visual feedback shown while dragging
  Widget _buildDragFeedback(BuildContext context, Place place) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      color: Theme.of(context).brightness == Brightness.light 
        ? place.category.lightColor.withOpacity(0.7)
        : place.category.darkColor.withOpacity(0.7),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeedbackIcon(context, place),
              const SizedBox(width: 8),
              Flexible(
                child: _buildFeedbackText(context, place),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the icon for drag feedback
  Widget _buildFeedbackIcon(BuildContext context, Place place) {
    return Icon(
      place.category.icon, 
      size: 24, 
      color: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black,
    );
  }

  /// Builds the text content for drag feedback
  Widget _buildFeedbackText(BuildContext context, Place place) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          place.displayName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (place.formattedAddress.isNotEmpty)
          Text(
            place.formattedAddress,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                ? Colors.white.withOpacity(0.9)
                : Colors.black.withOpacity(0.9),
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// Builds the clickable place chip
  Widget _buildPlaceChip(BuildContext context, Place place) {
    return GestureDetector(
      onTap: () => _navigateToPlace(context, place),
      child: Card(
        elevation: 0,
        color: _getChipColor(context, place),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildChipIcon(context, place),
              const SizedBox(width: 6),
              Flexible(
                child: _buildChipText(context, place),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the appropriate color for the place chip
  Color _getChipColor(BuildContext context, Place place) {
    return Theme.of(context).brightness == Brightness.light 
      ? place.category.lightColor.withOpacity(0.6)
      : place.category.darkColor.withOpacity(0.6);
  }

  /// Builds the icon for the place chip
  Widget _buildChipIcon(BuildContext context, Place place) {
    return Icon(
      place.category.icon, 
      size: 18, 
      color: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black,
    );
  }

  /// Builds the text for the place chip
  Widget _buildChipText(BuildContext context, Place place) {
    return Text(
      place.displayName,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Navigates to the place detail page
  void _navigateToPlace(BuildContext context, Place place) {
    context.push('/place/${place.placeId}', extra: place);
  }
}