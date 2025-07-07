import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/config.dart';
import '../../../core/providers/infrastructure_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../place/services/google_places_service.dart';
import '../../place/services/places_service.dart';
import '../../place/services/recommendation_service.dart';
import '../../place/services/recommendation_service_impl.dart';
import '../models/user_data.dart';
import '../services/profile_service.dart';
import '../services/traveler_profile_service.dart';
import '../services/user_deletion_service.dart';
import '../services/user_management_service.dart';

/// Authentication state changes provider
final authStateChangesProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

/// User data provider
final userDataProvider = StreamProvider<UserData?>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return FirebaseAuth.instance.authStateChanges().asyncExpand(
    (user) =>
        user == null ? const Stream.empty() : service.streamUser(user.uid),
  );
});

/// Locale provider
final localeProvider = StateProvider<Locale?>((ref) => const Locale('en'));

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// Places service provider
final placesServiceProvider = Provider<PlacesService>((ref) {
  return GooglePlacesService(googlePlacesApiKey);
});

/// Recommendation service provider
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationServiceImpl();
});

/// Profile service provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final challengeService = ref.watch(challengeRepositoryProvider);
  final challengeProgressService = ref.watch(challengeProgressRepositoryProvider);
  return ProfileService(
    firestoreService,
    challengeService,
    challengeProgressService,
  );
});

/// Traveler profile service provider
final travelerProfileServiceProvider = Provider<TravelerProfileService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return TravelerProfileService(firestoreService);
});

/// User deletion service provider
final userDeletionServiceProvider = Provider<UserDeletionService>((ref) {
  return UserDeletionService();
});

/// User management service provider
final userManagementServiceProvider = Provider<UserManagementService>((ref) {
  return UserManagementService();
});
