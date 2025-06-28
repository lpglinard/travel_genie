import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_service.dart';

class GroupsService {
  GroupsService(this._firestoreService);

  final FirestoreService _firestoreService;

  // Get current user ID
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Stream groups feedback summary
  Stream<Map<String, dynamic>?> streamGroupsFeedbackSummary() {
    return _firestoreService.streamGroupsFeedbackSummary();
  }

  // Stream user feedback
  Stream<Map<String, dynamic>?> streamUserFeedback() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }
    return _firestoreService.streamUserFeedback(userId);
  }

  // Submit feedback
  Future<void> submitFeedback(bool wantsGroupFeature) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User must be authenticated to submit feedback');
    }

    await _firestoreService.submitGroupsFeedback(
      userId: userId,
      wantsGroupFeature: wantsGroupFeature,
    );
  }

  // Check if user has submitted feedback
  Future<bool> hasUserSubmittedFeedback() async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      final userFeedback = await _firestoreService
          .streamUserFeedback(userId)
          .first;
      return userFeedback != null;
    } catch (e) {
      return false;
    }
  }

  // Get user's feedback response
  Future<bool?> getUserFeedbackResponse() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final userFeedback = await _firestoreService
          .streamUserFeedback(userId)
          .first;
      return userFeedback?['wantsGroupFeature'] as bool?;
    } catch (e) {
      return null;
    }
  }
}
