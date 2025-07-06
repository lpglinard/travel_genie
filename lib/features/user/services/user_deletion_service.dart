import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_genie/features/user/models/user_deletion_response.dart';

class UserDeletionService {
  UserDeletionService();

  /// Delete user using Firebase's default implementation
  /// This will delete the Firebase Auth user account directly
  Future<UserDeletionResponse> deleteAllUserData(String userId) async {
    try {
      // Get the current Firebase user
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return UserDeletionResponse(
          userId: userId,
          success: false,
          errorMessage: 'User not authenticated',
          message: 'No authenticated user found',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
      }

      // Verify the user ID matches
      if (currentUser.uid != userId) {
        return UserDeletionResponse(
          userId: userId,
          success: false,
          errorMessage: 'User ID mismatch',
          message: 'Cannot delete different user account',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
      }

      // Use Firebase's default implementation to delete the user
      await currentUser.delete();

      return UserDeletionResponse(
        userId: userId,
        success: true,
        message: 'User account deleted successfully',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      String errorMessage = 'Firebase Auth error: ${e.code}';
      switch (e.code) {
        case 'requires-recent-login':
          errorMessage = 'Please sign in again before deleting your account';
          break;
        case 'user-not-found':
          errorMessage = 'User account not found';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }

      return UserDeletionResponse(
        userId: userId,
        success: false,
        errorMessage: errorMessage,
        message: 'Failed to delete user account',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Handle other errors
      return UserDeletionResponse(
        userId: userId,
        success: false,
        errorMessage: 'Unexpected error: ${e.toString()}',
        message: 'Failed to delete user account',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}
