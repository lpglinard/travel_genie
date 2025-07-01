import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_genie/trip/services/trip_service.dart';
import 'package:travel_genie/trip/models/trip_participant.dart';
import 'package:travel_genie/models/trip.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/models/location.dart';
import 'package:travel_genie/models/itinerary_day.dart';

// Mock implementation for testing
class MockTripRepository implements TripRepository {
  final Map<String, Trip> _trips = {};
  final Map<String, List<TripParticipant>> _participants = {};
  final Map<String, List<Place>> _places = {};
  final Map<String, List<ItineraryDay>> _itinerary = {};
  int _nextTripId = 1;

  void addMockTrip(Trip trip) {
    _trips[trip.id] = trip;
  }

  void addMockParticipants(String tripId, List<TripParticipant> participants) {
    _participants[tripId] = List<TripParticipant>.from(participants);
  }

  void addMockPlaces(String tripId, List<Place> places) {
    _places[tripId] = List<Place>.from(places);
  }

  void addMockItinerary(String tripId, List<ItineraryDay> itinerary) {
    _itinerary[tripId] = List<ItineraryDay>.from(itinerary);
  }

  @override
  Future<String> createTrip(Trip trip) async {
    final tripId = 'mock-trip-${_nextTripId++}';
    final tripWithId = trip.copyWith(id: tripId);
    _trips[tripId] = tripWithId;
    return tripId;
  }

  @override
  Future<Trip?> getTripById(String tripId) async {
    return _trips[tripId];
  }

  @override
  Stream<Trip?> streamTripById(String tripId) {
    return Stream.value(_trips[tripId]);
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

    test('should create trip successfully', () async {
      // Arrange
      final trip = Trip(
        id: '', // Will be set by createTrip
        title: 'New York Adventure',
        description: 'A wonderful trip to New York',
        startDate: DateTime(2024, 12, 1),
        endDate: DateTime(2024, 12, 8),
        coverImageUrl: 'https://example.com/nyc.jpg',
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final tripId = await tripService.createTrip(trip);

      // Assert
      expect(tripId, isNotEmpty);
      expect(tripId, startsWith('mock-trip-'));

      // Verify trip was stored
      final storedTrip = await tripService.getTripDetails(tripId);
      expect(storedTrip, isNotNull);
      expect(storedTrip!.title, equals('New York Adventure'));
      expect(storedTrip.id, equals(tripId));
    });

    test('should stream trip details correctly', () async {
      // Arrange
      final trip = Trip(
        id: 'stream-test-trip',
        title: 'Stream Test Trip',
        description: 'A trip for testing streaming',
        startDate: DateTime(2024, 11, 1),
        endDate: DateTime(2024, 11, 8),
        coverImageUrl: 'https://example.com/stream.jpg',
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.addMockTrip(trip);

      // Act
      final stream = tripService.streamTripDetails('stream-test-trip');

      // Assert
      await expectLater(
        stream,
        emits(predicate<Trip?>((t) => 
          t != null && 
          t.id == 'stream-test-trip' && 
          t.title == 'Stream Test Trip'
        )),
      );
    });

    test('should stream null for non-existent trip', () async {
      // Act
      final stream = tripService.streamTripDetails('non-existent-trip');

      // Assert
      await expectLater(stream, emits(isNull));
    });

    test('should get trip with details including places and itinerary', () async {
      // Arrange
      final trip = Trip(
        id: 'detailed-trip',
        title: 'Detailed Trip',
        description: 'A trip with places and itinerary',
        startDate: DateTime(2024, 11, 15),
        endDate: DateTime(2024, 11, 22),
        coverImageUrl: 'https://example.com/detailed.jpg',
        userId: 'user-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final places = [
        Place(
          placeId: 'place-1',
          displayName: 'Eiffel Tower',
          displayNameLanguageCode: 'en',
          formattedAddress: 'Paris, France',
          googleMapsUri: 'https://maps.google.com/?q=Eiffel+Tower',
          location: const Location(lat: 48.8584, lng: 2.2945),
          types: const ['tourist_attraction'],
        ),
        Place(
          placeId: 'place-2',
          displayName: 'Louvre Museum',
          displayNameLanguageCode: 'en',
          formattedAddress: 'Paris, France',
          googleMapsUri: 'https://maps.google.com/?q=Louvre+Museum',
          location: const Location(lat: 48.8606, lng: 2.3376),
          types: const ['museum'],
        ),
      ];

      final itinerary = [
        ItineraryDay(
          id: 'day-1',
          date: DateTime(2024, 11, 15),
          order: 0,
          places: [],
        ),
        ItineraryDay(
          id: 'day-2',
          date: DateTime(2024, 11, 16),
          order: 1,
          places: [],
        ),
      ];

      mockRepository.addMockTrip(trip);
      mockRepository.addMockPlaces('detailed-trip', places);
      mockRepository.addMockItinerary('detailed-trip', itinerary);

      // Act
      final result = await tripService.getTripWithDetails('detailed-trip');

      // Assert
      expect(result.id, equals('detailed-trip'));
      expect(result.title, equals('Detailed Trip'));
      expect(result.places, hasLength(2));
      expect(result.places![0].displayName, equals('Eiffel Tower'));
      expect(result.places![1].displayName, equals('Louvre Museum'));
      expect(result.itinerary, hasLength(2));
      expect(result.itinerary![0].date, equals(DateTime(2024, 11, 15)));
      expect(result.itinerary![1].date, equals(DateTime(2024, 11, 16)));
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
