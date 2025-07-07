import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/core/providers/infrastructure_providers.dart';
import 'package:travel_genie/core/widgets/login_required_dialog.dart';
import 'package:travel_genie/features/challenge/providers/challenge_providers.dart';
import 'package:travel_genie/features/trip/models/trip.dart';
import 'package:travel_genie/features/trip/widgets/date_range_picker_field.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import '../providers/trip_providers.dart';
import '../services/city_autocomplete_service.dart';
import '../widgets/destination_autocomplete_field.dart';
import '../widgets/profile_completeness/profile_completeness_widget.dart';
import '../widgets/travel_partner/travel_partner_invite_widget.dart';

class NewTripScreen extends ConsumerStatefulWidget {
  const NewTripScreen({super.key});

  @override
  ConsumerState<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends ConsumerState<NewTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();

  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Log trip creation flow started
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(analyticsServiceProvider)
          .analytics
          .logEvent(
            name: 'begin_trip_creation',
            parameters: {
              'screen_name': 'new_trip_screen',
              'content_type': 'trip_creation_flow',
            },
          );
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _startPlanning() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      return;
    }

    // Dates are now mandatory - check if dates are selected
    if (_selectedDateRange == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.pleaseSelectTravelDatesToContinue,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user - Use Firebase Auth directly for immediate and reliable access
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Show login dialog instead of error message
        await LoginRequiredDialog.show(context);
        return;
      }

      // Get the selected suggestion with rich data
      var selectedSuggestion = ref.read(selectedDestinationSuggestionProvider);

      // If no suggestion was selected, fetch suggestions and use the first result
      if (selectedSuggestion == null) {
        final cityService = ref.read(cityAutocompleteServiceProvider);
        final suggestions = await cityService.searchCities(destination);

        if (suggestions.isNotEmpty) {
          selectedSuggestion = suggestions.first;
          // Store the fetched suggestion for consistency
          ref.read(selectedDestinationSuggestionProvider.notifier).state =
              selectedSuggestion;
        } else {
          // If no suggestions found, show error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.noValidDestinationFound(destination),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
      }

      // Get trip service
      final tripService = ref.read(tripServiceProvider);

      // Create trip object with rich destination data
      final now = DateTime.now();
      final trip = Trip(
        id: '',
        // Will be set by Firestore
        title: selectedSuggestion?.placePrediction.mainText ?? destination,
        description:
            'Trip to ${selectedSuggestion?.placePrediction.formattedText ?? destination}',
        startDate: _selectedDateRange!.start,
        endDate: _selectedDateRange!.end,
        coverImageUrl: '',
        isLoadingCoverImage: true,
        isLoadingDescription: true,
        isLoadingItinerary: true,
        userId: currentUser.uid,
        createdAt: now,
        updatedAt: now,
        placeId: selectedSuggestion?.placePrediction.placeId,
        isArchived: false,
        participants: [currentUser.uid], // Add creator as first participant
      );

      // Create trip in Firestore
      final tripId = await tripService.createTrip(trip);

      // Track challenge progress for creating a trip
      try {
        final challengeActions = ref.read(challengeActionsProvider);
        await challengeActions.markCompleted(currentUser.uid, 'create_trip');
        debugPrint(
          '[DEBUG_LOG] Create trip challenge marked as completed for user ${currentUser.uid}',
        );
      } catch (e) {
        // Log error but don't prevent the trip creation success flow
        debugPrint('Error tracking create_trip challenge: $e');
      }

      // Clear the stored suggestion after successful creation
      ref.read(selectedDestinationSuggestionProvider.notifier).state = null;

      // Navigate to trip details page
      if (mounted) {
        context.push('/trip/$tripId');
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorCreatingTrip(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the selected suggestion
    final selectedSuggestion = ref.watch(selectedDestinationSuggestionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.planNewTrip),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Destination Field
              DestinationAutocompleteField(
                controller: _destinationController,
                onSuggestionSelected: (suggestion) {
                  // Store the complete suggestion data
                  ref
                          .read(selectedDestinationSuggestionProvider.notifier)
                          .state =
                      suggestion;
                },
              ),

              const SizedBox(height: 24),

              // Date Range Picker
              DateRangePickerField(
                selectedDateRange: _selectedDateRange,
                onDateRangeSelected: (dateRange) {
                  setState(() {
                    _selectedDateRange = dateRange;
                  });
                },
              ),

              const SizedBox(height: 24),

              // AI Personalization Block
              const ProfileCompletenessWidget(),
              const SizedBox(height: 24),
              // Travel Partner Invite
              const TravelPartnerInviteWidget(),

              const SizedBox(height: 32),

              // Start Planning Button
              ElevatedButton(
                onPressed: _isLoading ? null : _startPlanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B6EFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.startPlanning,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
