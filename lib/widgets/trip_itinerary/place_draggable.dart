import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/drag_drop_models.dart';
import '../../models/place.dart';
import '../../providers/user_providers.dart';

/// A draggable wrapper widget that makes any child widget draggable with place data.
///
/// This widget wraps a child widget and makes it draggable, providing visual feedback
/// during the drag operation. It's designed specifically for dragging places in the
/// trip itinerary interface.
class PlaceDraggable extends ConsumerWidget {
  /// The place data associated with this draggable widget
  final Place place;

  /// The ID of the day this place belongs to, if any
  final String fromDayId;

  /// The child widget to make draggable
  final Widget child;

  /// Creates a new [PlaceDraggable].
  ///
  /// [place] is the place data that will be transferred during drag operations.
  /// [fromDayId] identifies the source day for this place.
  /// [child] is the widget that will be made draggable.
  const PlaceDraggable({
    super.key,
    required this.place,
    required this.fromDayId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LongPressDraggable<DraggedPlaceData>(
      data: DraggedPlaceData(place: place, fromDayId: fromDayId),
      feedback: _buildDragFeedback(context),
      child: child,
      childWhenDragging: Opacity(opacity: 0.5, child: child),
      onDragStarted: () {
        ref
            .read(analyticsServiceProvider)
            .logDragStart(
              itemType: 'place',
              itemId: place.placeId,
              fromLocation: fromDayId,
            );
      },
    );
  }

  /// Builds the visual feedback shown while dragging
  Widget _buildDragFeedback(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      color: Theme.of(context).brightness == Brightness.light
          ? place.category.lightColor.withValues(alpha: 0.7)
          : place.category.darkColor.withValues(alpha: 0.7),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(context),
              const SizedBox(width: 12),
              Flexible(child: _buildTextContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the icon for the drag feedback
  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        place.category.icon,
        size: 24,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
      ),
    );
  }

  /// Builds the text content for the drag feedback
  Widget _buildTextContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          place.displayName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (place.formattedAddress.isNotEmpty)
          Text(
            place.formattedAddress,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.9),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
      ],
    );
  }
}
