import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/config.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../challenge/services/challenge_actions_repository.dart';
import '../../challenge/services/challenge_actions_service.dart';
import '../../challenge/services/challenge_progress_repository.dart';
import '../../challenge/services/challenge_progress_service.dart';
import '../../challenge/services/challenge_repository.dart';
import '../../challenge/services/challenge_service.dart';
import '../../place/services/google_places_service.dart';
import '../../place/services/places_service.dart';
import '../../place/services/recommendation_service.dart';
import '../../place/services/recommendation_service_impl.dart';
import '../models/user_data.dart';
import '../services/profile_service.dart';
import '../services/traveler_profile_service.dart';
import '../services/user_deletion_service.dart';
import '../services/user_management_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final preferencesServiceProvider = FutureProvider<PreferencesService>((
  ref,
) async {
  final prefs = await ref.watch(sharedPrefsProvider.future);
  return PreferencesService(prefs);
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final authStateChangesProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final userDataProvider = StreamProvider<UserData?>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return FirebaseAuth.instance.authStateChanges().asyncExpand(
    (user) =>
        user == null ? const Stream.empty() : service.streamUser(user.uid),
  );
});

final localeProvider = StateProvider<Locale?>((ref) => const Locale('en'));

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final placesServiceProvider = Provider<PlacesService>((ref) {
  return GooglePlacesService(googlePlacesApiKey);
});

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationServiceImpl();
});

final challengeServiceProvider = Provider<ChallengeRepository>((ref) {
  return FirestoreChallengeRepository(FirebaseFirestore.instance);
});

final challengeProgressServiceProvider = Provider<ChallengeProgressRepository>((
  ref,
) {
  return FirestoreChallengeProgressRepository(FirebaseFirestore.instance);
});

final challengeActionsProvider = Provider<ChallengeActionsRepository>((ref) {
  final progressRepository = ref.watch(challengeProgressServiceProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return FirestoreChallengeActionsRepository(progressRepository, analyticsService);
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final challengeService = ref.watch(challengeServiceProvider);
  final challengeProgressService = ref.watch(challengeProgressServiceProvider);
  return ProfileService(
    firestoreService,
    challengeService,
    challengeProgressService,
  );
});

final travelerProfileServiceProvider = Provider<TravelerProfileService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return TravelerProfileService(firestoreService);
});

final userDeletionServiceProvider = Provider<UserDeletionService>((ref) {
  return UserDeletionService();
});

final userManagementServiceProvider = Provider<UserManagementService>((ref) {
  return UserManagementService();
});
