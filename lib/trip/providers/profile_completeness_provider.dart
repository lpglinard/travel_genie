import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/user_providers.dart';

import '../widgets/profile_completeness_widget.dart';

/// Provider for profile completeness calculation
/// Follows Dependency Inversion Principle - depends on abstractions (userDataProvider)
final profileCompletenessProvider = FutureProvider<ProfileCompleteness>((
  ref,
) async {
  final userData = await ref.watch(userDataProvider.future);

  // Convert UserData to Map for ProfileCompleteness.fromUserData
  Map<String, dynamic>? userDataMap;
  if (userData != null) {
    userDataMap = {
      'name': userData.name,
      'email': userData.email,
      'locale': userData.locale,
      // Add other fields as they become available in UserData model
      // For now, we'll simulate some missing fields to show progress
    };
  }

  return ProfileCompleteness.fromUserData(userDataMap);
});
