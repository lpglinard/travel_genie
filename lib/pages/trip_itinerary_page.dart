import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/drag_drop_models.dart';
import '../models/place.dart';
import '../providers/itinerary_providers.dart';
import '../providers/trip_service_provider.dart';
import '../providers/user_providers.dart';
import '../services/itinerary_drag_drop_service.dart';
import '../services/magic_ai_optimizer_service.dart';
import '../widgets/trip_itinerary/day_item.dart';
import '../widgets/trip_itinerary/magic_ai_optimizer_bottom_sheet.dart';
import '../widgets/trip_itinerary/magic_animation_overlay.dart';
import '../widgets/trip_itinerary/saved_places_bin.dart';

/// A page that displays and manages a trip's itinerary.
///
/// This page allows users to view and organize their trip itinerary by:
/// - Viewing saved places that can be added to days
/// - Organizing places within specific days via drag-and-drop
/// - Reordering places within days
/// - Moving places between different days
/// - Optimizing the trip using Magic AI Trip Optimizer
///
/// The page uses extracted widgets and services for better maintainability:
/// - [SavedPlacesBin] for displaying draggable saved places
/// - [DayItem] for displaying individual itinerary days
/// - [ItineraryDragDropService] for handling drag-and-drop business logic
/// - [MagicAiOptimizerService] for AI-powered trip optimization
class TripItineraryPage extends ConsumerStatefulWidget {
  /// The ID of the trip whose itinerary is being displayed
  final String tripId;

  /// Creates a new [TripItineraryPage].
  ///
  /// [tripId] is required and identifies the trip whose itinerary to display.
  const TripItineraryPage({super.key, required this.tripId});

  @override
  ConsumerState<TripItineraryPage> createState() => _TripItineraryPageState();
}

class _TripItineraryPageState extends ConsumerState<TripItineraryPage> {
  bool _isOptimizing = false;
  String? _currentOptimizationStrategy;
  final MagicAiOptimizerService _optimizerService = MagicAiOptimizerService();

  @override
  Widget build(BuildContext context) {
    final daysAsync = ref.watch(itineraryDaysProvider(widget.tripId));
    final savedPlacesAsync = ref.watch(savedPlacesProvider);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Navigate back to the previous screen
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          // If can't pop, go to trips page
          GoRouter.of(context).go('/trips');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.tripItinerary,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              ref
                  .read(analyticsServiceProvider)
                  .logButtonTap(
                    buttonName: 'back_button',
                    screenName: 'trip_itinerary',
                    context: 'app_bar',
                  );
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                GoRouter.of(context).go('/trips');
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.auto_fix_high,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: _isOptimizing
                  ? null
                  : () {
                      ref
                          .read(analyticsServiceProvider)
                          .logButtonTap(
                            buttonName: 'magic_ai_optimizer',
                            screenName: 'trip_itinerary',
                            context: 'app_bar',
                          );
                      _showMagicAiOptimizerBottomSheet();
                    },
              tooltip: 'Magic AI Trip Optimizer',
            ),
          ],
        ),
        body: daysAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.errorGeneric(e.toString()))),
          data: (days) {
            return savedPlacesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(l10n.errorLoadingSavedPlaces(e.toString())),
              ),
              data: (savedPlaces) {
                final placesByDay = {
                  for (final day in days)
                    day.id: ref
                        .watch(
                          placesForDayProvider((
                            tripId: widget.tripId,
                            dayId: day.id,
                          )),
                        )
                        .maybeWhen(
                          data: (places) => places,
                          orElse: () => <Place>[],
                        ),
                };

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.savedPlaces,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SavedPlacesBin(places: savedPlaces),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Divider(
                          height: 32,
                          thickness: 1,
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      ...days.map((day) {
                        final places = placesByDay[day.id] ?? [];
                        return DayItem(
                          day: day,
                          places: places,
                          onPlaceAccepted:
                              (DraggedPlaceData data, int insertIndex) async {
                                ref
                                    .read(analyticsServiceProvider)
                                    .logDragEnd(
                                      itemType: 'place',
                                      itemId: data.place.placeId,
                                      toLocation: day.id,
                                      successful: true,
                                    );
                                final dragDropService = ref.read(
                                  itineraryDragDropServiceProvider(
                                    widget.tripId,
                                  ),
                                );
                                await dragDropService.handlePlaceDrop(
                                  data: data,
                                  targetDayId: day.id,
                                  insertIndex: insertIndex,
                                  currentPlaces: places,
                                );
                              },
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Shows the magic AI optimizer bottom sheet
  void _showMagicAiOptimizerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          MagicAiOptimizerBottomSheet(onOptimizationStart: _startOptimization),
    );
  }

  /// Starts the magic AI optimization process
  void _startOptimization(OptimizationStrategy strategy) async {
    setState(() {
      _isOptimizing = true;
      _currentOptimizationStrategy = _getStrategyName(strategy);
    });

    // Show the magic animation overlay
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (context) => MagicAnimationOverlay(
          strategyName: _currentOptimizationStrategy!,
          onAnimationComplete: () {
            Navigator.of(context).pop();
            _handleOptimizationComplete();
          },
        ),
      );
    }

    try {
      // Call the fake API
      final result = await _optimizerService.optimizeTrip(
        strategy: strategy,
        tripId: widget.tripId,
      );

      if (mounted) {
        _showOptimizationResult(result);
      }
    } catch (e) {
      if (mounted) {
        _showOptimizationError(e.toString());
      }
    }
  }

  /// Handles optimization completion
  void _handleOptimizationComplete() {
    setState(() {
      _isOptimizing = false;
      _currentOptimizationStrategy = null;
    });
  }

  /// Shows the optimization result to the user
  void _showOptimizationResult(MagicAiOptimizationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Optimization Complete!',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your trip has been optimized using the ${result.strategyName} strategy.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Improvements found:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.improvementsFound.map(
              (improvement) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        improvement,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(analyticsServiceProvider)
                  .logDialogInteraction(
                    dialogType: 'optimization_result',
                    action: 'confirm',
                    screenName: 'trip_itinerary',
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  /// Shows optimization error to the user
  void _showOptimizationError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Optimization Failed',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'Sorry, we encountered an issue while optimizing your trip: $error',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(analyticsServiceProvider)
                  .logDialogInteraction(
                    dialogType: 'optimization_error',
                    action: 'dismiss',
                    screenName: 'trip_itinerary',
                  );
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Gets the human-readable name for a strategy
  String _getStrategyName(OptimizationStrategy strategy) {
    switch (strategy) {
      case OptimizationStrategy.timeEfficient:
        return 'Time Efficient';
      case OptimizationStrategy.costEffective:
        return 'Cost Effective';
      case OptimizationStrategy.experienceMaximizer:
        return 'Experience Maximizer';
    }
  }
}
