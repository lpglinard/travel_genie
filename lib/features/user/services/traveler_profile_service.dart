import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_genie/core/services/firestore_service.dart';

import '../models/traveler_profile.dart';

class TravelerProfileService {
  TravelerProfileService(this._firestoreService);

  final FirestoreService _firestoreService;

  /// Get the current user ID
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Get the saved traveler profile
  Future<TravelerProfile?> getProfile() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    return await _firestoreService.getTravelerProfile(userId);
  }

  /// Stream the traveler profile
  Stream<TravelerProfile?> streamProfile() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value(null);

    return _firestoreService.streamTravelerProfile(userId);
  }

  /// Save the traveler profile
  Future<void> saveProfile(TravelerProfile profile) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User must be authenticated to save traveler profile');
    }

    await _firestoreService.saveTravelerProfile(userId, profile);
  }

  /// Clear the saved traveler profile
  Future<void> clearProfile() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User must be authenticated to clear traveler profile');
    }

    await _firestoreService.deleteTravelerProfile(userId);
  }

  /// Check if a profile exists
  Future<bool> hasProfile() async {
    final userId = _currentUserId;
    if (userId == null) return false;

    return await _firestoreService.hasTravelerProfile(userId);
  }

  /// Get profile completion percentage (0.0 to 1.0)
  Future<double> getCompletionPercentage() async {
    final currentProfile = await getProfile();
    if (currentProfile == null) return 0.0;

    int completedFields = 0;
    int totalFields = 6; // Total number of profile sections

    if (currentProfile.travelCompany.isNotEmpty) completedFields++;
    if (currentProfile.budget != null) completedFields++;
    if (currentProfile.accommodationTypes.isNotEmpty) completedFields++;
    if (currentProfile.interests.isNotEmpty) completedFields++;
    if (currentProfile.gastronomicPreferences.isNotEmpty) completedFields++;
    if (currentProfile.itineraryStyle != null) completedFields++;

    return completedFields / totalFields;
  }
}
