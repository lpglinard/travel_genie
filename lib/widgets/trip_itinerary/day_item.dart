import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/itinerary_day.dart';
import '../../models/place.dart';
import '../../models/drag_drop_models.dart';
import 'drag_target_slot.dart';
import 'place_draggable.dart';

/// A widget that displays a single day in the trip itinerary.
/// 
/// This widget shows the day's date, summary, and all places assigned to it.
/// It supports drag-and-drop functionality for reordering places within the day
/// and accepting new places from other days or the saved places bin.
class DayItem extends StatelessWidget {
  /// The itinerary day to display
  final ItineraryDay day;
  
  /// The list of places assigned to this day
  final List<Place> places;
  
  /// Callback function called when a place is dropped on this day
  final Future<void> Function(DraggedPlaceData data, int insertIndex) onPlaceAccepted;

  /// Creates a new [DayItem].
  /// 
  /// [day] is the itinerary day data to display.
  /// [places] is the list of places assigned to this day.
  /// [onPlaceAccepted] is called when a place is dropped on this day.
  const DayItem({
    super.key,
    required this.day,
    required this.places,
    required this.onPlaceAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDayHeader(context),
            _buildPlacesList(context),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with day information
  Widget _buildDayHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          _formatDayDate(day.date, context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: _buildDaySummary(context),
      ),
    );
  }

  /// Builds the day summary if available
  Widget? _buildDaySummary(BuildContext context) {
    if (day.summary != null && day.summary!.isNotEmpty) {
      return Text(day.summary!);
    }
    return null;
  }

  /// Builds the list of places with drag-and-drop functionality
  Widget _buildPlacesList(BuildContext context) {
    return Column(
      children: [
        // Drop zone before the first place
        DragTargetSlot(
          onPlaceAccepted: (data) => onPlaceAccepted(data, 0),
        ),
        // Places with drop zones after each one
        ...List.generate(places.length, (index) {
          final place = places[index];
          return Column(
            children: [
              _buildPlaceItem(context, place, index),
              DragTargetSlot(
                onPlaceAccepted: (data) => onPlaceAccepted(data, index + 1),
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Builds a single place item within the day
  Widget _buildPlaceItem(BuildContext context, Place place, int index) {
    return PlaceDraggable(
      place: place,
      fromDayId: day.id,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: _buildPlaceListTile(context, place),
        ),
      ),
    );
  }

  /// Builds the ListTile for a place
  Widget _buildPlaceListTile(BuildContext context, Place place) {
    return ListTile(
      key: ValueKey(place.displayName),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: _buildPlaceIcon(context, place),
      title: _buildPlaceTitle(context, place),
      subtitle: _buildPlaceSubtitle(context, place),
      tileColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      onTap: () => _navigateToPlace(context, place),
    );
  }

  /// Builds the icon for a place
  Widget _buildPlaceIcon(BuildContext context, Place place) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
          ? place.category.lightColor.withOpacity(0.15)
          : place.category.darkColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        place.category.icon,
        size: 24,
        color: Theme.of(context).brightness == Brightness.light
          ? place.category.lightColor
          : place.category.darkColor,
      ),
    );
  }

  /// Builds the title for a place
  Widget _buildPlaceTitle(BuildContext context, Place place) {
    return Text(
      place.displayName,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Builds the subtitle for a place
  Widget? _buildPlaceSubtitle(BuildContext context, Place place) {
    if (place.formattedAddress.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          place.formattedAddress,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return null;
  }

  /// Formats the day date according to the current locale
  String _formatDayDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dayFormat = DateFormat('EEEE', locale); // Full day name
    final dateFormat = DateFormat('d MMM yyyy', locale); // Day, month, year
    return '${dayFormat.format(date)}, ${dateFormat.format(date)}';
  }

  /// Navigates to the place detail page
  void _navigateToPlace(BuildContext context, Place place) {
    context.push('/place/${place.placeId}', extra: place);
  }
}