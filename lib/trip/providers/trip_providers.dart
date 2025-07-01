import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/models/trip.dart';

import '../models/autocomplete_models.dart';
import '../models/trip_participant.dart';
import '../services/trip_service.dart';

/// Provider for FirebaseFirestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for TripRepository
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreTripRepository(firestore);
});

/// Provider for TripService
final tripServiceProvider = Provider<TripService>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripService(repository);
});

/// Provider for trip details by ID with real-time updates
final tripDetailsProvider = StreamProvider.family<Trip?, String>((
  ref,
  tripId,
) {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.streamTripDetails(tripId);
});

/// Provider for trip with full details (including places and itinerary)
final tripWithDetailsProvider = FutureProvider.family<Trip, String>((
  ref,
  tripId,
) async {
  final tripService = ref.watch(tripServiceProvider);
  return await tripService.getTripWithDetails(tripId);
});

/// Provider for trip participants
final tripParticipantsProvider =
    FutureProvider.family<List<TripParticipant>, String>((ref, tripId) async {
      final tripService = ref.watch(tripServiceProvider);
      return await tripService.getParticipants(tripId);
    });

/// Provider for formatted date range
final tripDateRangeProvider = Provider.family<String, Trip>((ref, trip) {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.formatDateRange(trip.startDate, trip.endDate);
});

/// State notifier for managing trip participants
class TripParticipantsNotifier
    extends StateNotifier<AsyncValue<List<TripParticipant>>> {
  TripParticipantsNotifier(this._tripService, this._tripId)
    : super(const AsyncValue.loading()) {
    _loadParticipants();
  }

  final TripService _tripService;
  final String _tripId;

  Future<void> _loadParticipants() async {
    try {
      final participants = await _tripService.getParticipants(_tripId);
      state = AsyncValue.data(participants);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addParticipant(TripParticipant participant) async {
    try {
      await _tripService.addParticipant(_tripId, participant);
      await _loadParticipants(); // Reload participants
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeParticipant(String userId) async {
    try {
      await _tripService.removeParticipant(_tripId, userId);
      await _loadParticipants(); // Reload participants
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadParticipants();
  }
}

/// Provider for trip participants state notifier
final tripParticipantsNotifierProvider =
    StateNotifierProvider.family<
      TripParticipantsNotifier,
      AsyncValue<List<TripParticipant>>,
      String
    >((ref, tripId) {
      final tripService = ref.watch(tripServiceProvider);
      return TripParticipantsNotifier(tripService, tripId);
    });

/// Provider for current selected tab index
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for checking if current user is organizer
final isCurrentUserOrganizerProvider =
    Provider.family<bool, (List<TripParticipant>, String?)>((ref, params) {
      final (participants, currentUserId) = params;
      if (currentUserId == null) return false;

      final currentUserParticipant = participants.firstWhere(
        (p) => p.userId == currentUserId,
        orElse: () => const TripParticipant(
          userId: '',
          role: ParticipantRole.participant,
        ),
      );

      return currentUserParticipant.isOrganizer;
    });

/// State class for trip creation form data
/// Follows Single Responsibility Principle - only manages trip creation state
class TripCreationState {
  const TripCreationState({
    this.selectedSuggestion,
    this.selectedDateRange,
    this.additionalData,
  });

  final PlaceSuggestion? selectedSuggestion;
  final DateTimeRange? selectedDateRange;
  final Map<String, dynamic>? additionalData;

  TripCreationState copyWith({
    PlaceSuggestion? selectedSuggestion,
    DateTimeRange? selectedDateRange,
    Map<String, dynamic>? additionalData,
  }) {
    return TripCreationState(
      selectedSuggestion: selectedSuggestion ?? this.selectedSuggestion,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

/// Provider for storing selected destination suggestion during trip creation
/// Follows Single Responsibility Principle - only manages selected destination suggestion
final selectedDestinationSuggestionProvider = StateProvider<PlaceSuggestion?>(
  (ref) => null,
);

/// Provider for trip creation form state
/// Follows Single Responsibility Principle - only manages trip creation form state
final tripCreationStateProvider = StateProvider<TripCreationState>(
  (ref) => const TripCreationState(),
);
