import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/features/trip/models/trip.dart';

void main() {
  group('TripService - streamUserTrips logic', () {
    test('should combine and deduplicate trips correctly', () {
      const userId = 'user123';
      const otherUserId = 'user456';

      final now = DateTime.now();

      // Create test trips
      final createdTrip = Trip(
        id: 'trip1',
        title: 'Created Trip',
        description: 'Trip created by user',
        startDate: now,
        endDate: now.add(const Duration(days: 3)),
        coverImageUrl: 'https://example.com/image1.jpg',
        userId: userId,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        participants: [userId],
      );

      final participantTrip = Trip(
        id: 'trip2',
        title: 'Participant Trip',
        description: 'Trip where user is participant',
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
        coverImageUrl: 'https://example.com/image2.jpg',
        userId: otherUserId,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        participants: [otherUserId, userId], // User is participant
      );

      final duplicateTrip = Trip(
        id: 'trip1', // Same ID as createdTrip
        title: 'Duplicate Trip',
        description: 'This should be deduplicated',
        startDate: now,
        endDate: now.add(const Duration(days: 3)),
        coverImageUrl: 'https://example.com/image1.jpg',
        userId: userId,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        participants: [userId],
      );

      // Simulate the logic from streamUserTrips method
      final createdTrips = [createdTrip];
      final participantTrips = [participantTrip, duplicateTrip];

      // Combine trips and remove duplicates based on trip ID
      final allTrips = <String, Trip>{};

      // Add created trips
      for (final trip in createdTrips) {
        allTrips[trip.id] = trip;
      }

      // Add participant trips (will not overwrite if already exists)
      for (final trip in participantTrips) {
        allTrips[trip.id] ??= trip;
      }

      // Convert back to list and sort by creation date (descending)
      final sortedTrips = allTrips.values.toList();
      sortedTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Verify results
      expect(sortedTrips.length, 2); // Should have 2 unique trips
      expect(sortedTrips.map((t) => t.id).toSet(), {'trip1', 'trip2'});

      // Verify sorting (most recent first)
      expect(sortedTrips.first.id, 'trip2'); // More recent
      expect(sortedTrips.last.id, 'trip1'); // Older

      // Verify deduplication (should keep the first occurrence)
      final trip1 = sortedTrips.firstWhere((t) => t.id == 'trip1');
      expect(
        trip1.title,
        'Created Trip',
      ); // Should be the original, not the duplicate
    });

    test('should handle empty lists correctly', () {
      final createdTrips = <Trip>[];
      final participantTrips = <Trip>[];

      // Simulate the logic from streamUserTrips method
      final allTrips = <String, Trip>{};

      for (final trip in createdTrips) {
        allTrips[trip.id] = trip;
      }

      for (final trip in participantTrips) {
        allTrips[trip.id] ??= trip;
      }

      final sortedTrips = allTrips.values.toList();
      sortedTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(sortedTrips, isEmpty);
    });

    test('should handle single trip correctly', () {
      const userId = 'user123';
      final now = DateTime.now();

      final singleTrip = Trip(
        id: 'trip1',
        title: 'Single Trip',
        description: 'Only trip',
        startDate: now,
        endDate: now.add(const Duration(days: 3)),
        coverImageUrl: 'https://example.com/image1.jpg',
        userId: userId,
        createdAt: now,
        updatedAt: now,
        participants: [userId],
      );

      final createdTrips = [singleTrip];
      final participantTrips = <Trip>[];

      // Simulate the logic
      final allTrips = <String, Trip>{};

      for (final trip in createdTrips) {
        allTrips[trip.id] = trip;
      }

      for (final trip in participantTrips) {
        allTrips[trip.id] ??= trip;
      }

      final sortedTrips = allTrips.values.toList();
      sortedTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(sortedTrips.length, 1);
      expect(sortedTrips.first.id, 'trip1');
      expect(sortedTrips.first.title, 'Single Trip');
    });

    test('should verify participant filtering logic', () {
      const userId = 'user123';
      const otherUserId = 'user456';
      final now = DateTime.now();

      // Trip where user is creator
      final createdTrip = Trip(
        id: 'trip1',
        title: 'Created Trip',
        description: 'Trip created by user',
        startDate: now,
        endDate: now.add(const Duration(days: 3)),
        coverImageUrl: 'https://example.com/image1.jpg',
        userId: userId,
        createdAt: now,
        updatedAt: now,
        participants: [userId],
      );

      // Trip where user is participant but not creator
      final participantTrip = Trip(
        id: 'trip2',
        title: 'Participant Trip',
        description: 'Trip where user is participant',
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
        coverImageUrl: 'https://example.com/image2.jpg',
        userId: otherUserId,
        createdAt: now,
        updatedAt: now,
        participants: [otherUserId, userId], // User is participant
      );

      // Trip where user is neither creator nor participant
      final unrelatedTrip = Trip(
        id: 'trip3',
        title: 'Unrelated Trip',
        description: 'Trip user has no relation to',
        startDate: now,
        endDate: now.add(const Duration(days: 2)),
        coverImageUrl: 'https://example.com/image3.jpg',
        userId: otherUserId,
        createdAt: now,
        updatedAt: now,
        participants: [otherUserId],
      );

      // Test filtering logic for created trips (userId matches)
      final createdTrips = [
        createdTrip,
        participantTrip,
        unrelatedTrip,
      ].where((trip) => trip.userId == userId).toList();
      expect(createdTrips.length, 1);
      expect(createdTrips.first.id, 'trip1');

      // Test filtering logic for participant trips (participants contains userId)
      final participantTrips = [
        createdTrip,
        participantTrip,
        unrelatedTrip,
      ].where((trip) => trip.participants.contains(userId)).toList();
      expect(participantTrips.length, 2); // trip1 and trip2
      expect(participantTrips.map((t) => t.id).toSet(), {'trip1', 'trip2'});
    });
  });
}
