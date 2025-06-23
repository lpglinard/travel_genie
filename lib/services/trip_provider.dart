import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip.dart';
import 'firestore_service.dart';

class TripService {
  final FirestoreService _firestoreService;
  TripService(this._firestoreService);

  /// Stream trips for the current user
  Stream<List<Trip>> getUserTrips() {
    final user = FirebaseAuth.instance.currentUser;

    // If no user is logged in, return an empty list
    if (user == null) {
      return Stream.value([]);
    }

    // Use FirestoreService to stream user trips
    return _firestoreService.streamUserTrips(user.uid, user.email);
  }

  /// Create a new trip
  Future<String> createTrip({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String coverImageUrl = '',
    bool isArchived = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    return _firestoreService.createTrip(
      userId: user.uid,
      userEmail: user.email,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      coverImageUrl: coverImageUrl,
      isArchived: isArchived,
    );
  }

  // Add other trip-related methods here
}