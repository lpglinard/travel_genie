import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/models/user_deletion_response.dart';
import 'package:travel_genie/services/user_deletion_service.dart';

class UserManagementService {
  UserManagementService({UserDeletionService? userDeletionService})
    : _userDeletionService = userDeletionService ?? UserDeletionService();

  final UserDeletionService _userDeletionService;

  /// Delete all user data using Firebase's default implementation
  /// Returns a UserDeletionResponse indicating success or failure
  Future<UserDeletionResponse> deleteAllUserData(
    String userId,
    WidgetRef ref,
  ) async {
    return await _userDeletionService.deleteAllUserData(userId);
  }
}
