import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/services/profile_completeness_service.dart';
import 'package:travel_genie/user_providers.dart';

/// Provider for profile completeness calculation
/// Follows Dependency Inversion Principle - depends on abstractions (travelerProfileServiceProvider)
final profileCompletenessProvider = FutureProvider<ProfileCompletenessInfo>((
  ref,
) async {
  final travelerProfileService = ref.watch(travelerProfileServiceProvider);
  final profile = await travelerProfileService.getProfile();

  return ProfileCompletenessService.calculateCompleteness(profile);
});
