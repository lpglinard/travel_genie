import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_genie/trip/services/trip_service.dart';
import 'package:travel_genie/trip/models/trip_participant.dart';
import 'package:travel_genie/models/trip.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/models/itinerary_day.dart';

// Mock implementation for testing
class MockTripRepository implements TripRepository {
  final Map<String, Trip> _trips = {};
  final Map<String, List<TripParticipant>> _participants = {};
  final Map<String, List<Place>> _places = {};
  final Map<String, List<ItineraryDay>> _itinerary = {};

  void addMockTrip(Trip trip) {
    _trips[trip.id] = trip;
  }

  void addMockParticipants(String tripId, List<TripParticipant> participants) {
    _participants[tripId] = List<TripParticipant>.from(participants);
  }

  @override
  Future<Trip?> getTripById(String tripId) async {
    return _trips[tripId];
  }

  @override
  Future<List<TripParticipant>> getTripParticipants(String tripId) async {
    return _participants[tripId] ?? [];
  }

  @override
  Future<List<Place>> getTripPlaces(String tripId) async {
    return _places[tripId] ?? [];
  }

  @override
  Future<List<ItineraryDay>> getTripItinerary(String tripId) async {
    return _itinerary[tripId] ?? [];
  }

  @override
  Future<void> addParticipant(String tripId, TripParticipant participant) async {
    _participants[tripId] ??= [];
    _participants[tripId]!.add(participant);
  }

  @override
  Future<void> removeParticipant(String tripId, String userId) async {
    _participants[tripId]?.removeWhere((p) => p.userId == userId);
  }
}

void main() {
  group('TripService', () {
    late TripService tripService;
    late MockTripRepository mockRepository;

    setUp(() {
      mockRepository = MockTripRepository();
      tripService = TripService(mockRepository);
    });

    test('should return trip details when trip exists', () async {
      // Arrange
      final trip = Trip(
        id: 'test-trip-1',
        title: 'Paris Adventure',
        description: 'A wonderful trip to Paris',
        startDate: DateTime(2024, 10, 15),
        endDate: DateTime(2024, 10, 22),
        coverImageUrl: 'https://example.com/paris.jpg',
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.addMockTrip(trip);

      // Act
      final result = await tripService.getTripDetails('test-trip-1');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('test-trip-1'));
      expect(result.title, equals('Paris Adventure'));
    });

    test('should return null when trip does not exist', () async {
      // Act
      final result = await tripService.getTripDetails('non-existent-trip');

      // Assert
      expect(result, isNull);
    });

    test('should return participants sorted with organizers first', () async {
      // Arrange
      const participants = [
        TripParticipant(
          userId: 'user-2',
          role: ParticipantRole.participant,
          name: 'Bob Smith',
        ),
        TripParticipant(
          userId: 'user-1',
          role: ParticipantRole.organizer,
          name: 'Alice Johnson',
        ),
        TripParticipant(
          userId: 'user-3',
          role: ParticipantRole.participant,
          name: 'Charlie Brown',
        ),
      ];
      mockRepository.addMockParticipants('test-trip-1', participants);

      // Act
      final result = await tripService.getParticipants('test-trip-1');

      // Assert
      expect(result.length, equals(3));
      expect(result[0].isOrganizer, isTrue);
      expect(result[0].name, equals('Alice Johnson'));
      expect(result[1].isOrganizer, isFalse);
      expect(result[2].isOrganizer, isFalse);
    });

    test('should format date range correctly for same month', () async {
      // Arrange
      final startDate = DateTime(2024, 10, 15);
      final endDate = DateTime(2024, 10, 22);

      // Act
      final result = tripService.formatDateRange(startDate, endDate);

      // Assert
      expect(result, equals('Oct 15 - 22'));
    });

    test('should format date range correctly for different months', () async {
      // Arrange
      final startDate = DateTime(2024, 10, 28);
      final endDate = DateTime(2024, 11, 5);

      // Act
      final result = tripService.formatDateRange(startDate, endDate);

      // Assert
      expect(result, equals('Oct 28 - Nov 5'));
    });

    test('should add participant successfully', () async {
      // Arrange
      const participant = TripParticipant(
        userId: 'user-4',
        role: ParticipantRole.participant,
        name: 'David Wilson',
      );

      // Act
      await tripService.addParticipant('test-trip-1', participant);
      final participants = await tripService.getParticipants('test-trip-1');

      // Assert
      expect(participants.length, equals(1));
      expect(participants[0].userId, equals('user-4'));
      expect(participants[0].name, equals('David Wilson'));
    });

    test('should remove participant successfully', () async {
      // Arrange
      const participants = [
        TripParticipant(
          userId: 'user-1',
          role: ParticipantRole.organizer,
          name: 'Alice Johnson',
        ),
        TripParticipant(
          userId: 'user-2',
          role: ParticipantRole.participant,
          name: 'Bob Smith',
        ),
      ];
      mockRepository.addMockParticipants('test-trip-1', participants);

      // Act
      await tripService.removeParticipant('test-trip-1', 'user-2');
      final result = await tripService.getParticipants('test-trip-1');

      // Assert
      expect(result.length, equals(1));
      expect(result[0].userId, equals('user-1'));
    });

    test('should throw exception when trip not found for getTripWithDetails', () async {
      // Act & Assert
      expect(
        () => tripService.getTripWithDetails('non-existent-trip'),
        throwsA(isA<TripServiceException>()),
      );
    });
  });

  group('TripParticipant', () {
    test('should correctly identify organizer role', () {
      // Arrange
      const organizer = TripParticipant(
        userId: 'user-1',
        role: ParticipantRole.organizer,
        name: 'Alice Johnson',
      );
      const participant = TripParticipant(
        userId: 'user-2',
        role: ParticipantRole.participant,
        name: 'Bob Smith',
      );

      // Assert
      expect(organizer.isOrganizer, isTrue);
      expect(participant.isOrganizer, isFalse);
    });

    test('should return correct display name', () {
      // Arrange
      const participantWithName = TripParticipant(
        userId: 'user-1',
        role: ParticipantRole.participant,
        name: 'Alice Johnson',
      );
      const participantWithEmail = TripParticipant(
        userId: 'user-2',
        role: ParticipantRole.participant,
        email: 'bob@example.com',
      );
      const participantWithoutInfo = TripParticipant(
        userId: 'user-3',
        role: ParticipantRole.participant,
      );

      // Assert
      expect(participantWithName.displayName, equals('Alice Johnson'));
      expect(participantWithEmail.displayName, equals('bob@example.com'));
      expect(participantWithoutInfo.displayName, equals('Unknown User'));
    });
  });
}
