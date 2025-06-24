import 'package:flutter/material.dart';
import '../../models/drag_drop_models.dart';

/// A visual slot that accepts dragged places and provides visual feedback.
/// 
/// This widget creates a drop zone that changes appearance when a place
/// is being dragged over it, providing clear visual feedback to users
/// about where they can drop items.
class DragTargetSlot extends StatelessWidget {
  /// Callback function called when a place is dropped on this slot
  final Future<void> Function(DraggedPlaceData data) onPlaceAccepted;
  
  /// Creates a new [DragTargetSlot].
  /// 
  /// [onPlaceAccepted] is called when a place is successfully dropped on this slot.
  const DragTargetSlot({
    super.key,
    required this.onPlaceAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<DraggedPlaceData>(
      onWillAccept: (data) => data != null,
      onAccept: (data) async {
        await onPlaceAccepted(data);
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isActive ? 32 : 16,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isActive 
                ? Theme.of(context).colorScheme.secondaryContainer 
                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isActive 
              ? Center(
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                )
              : null,
          ),
        );
      },
    );
  }
}