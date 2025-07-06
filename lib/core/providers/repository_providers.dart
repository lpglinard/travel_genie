import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/challenge/services/challenge_progress_repository.dart';
import '../../features/challenge/services/challenge_progress_service.dart';
import '../../features/challenge/services/challenge_repository.dart';
import '../../features/challenge/services/challenge_service.dart';
import '../../features/trip/services/trip_service.dart';
import 'infrastructure_providers.dart';

/// Challenge repository provider
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreChallengeRepository(firestore);
});

/// Challenge progress repository provider
final challengeProgressRepositoryProvider =
    Provider<ChallengeProgressRepository>((ref) {
      final firestore = ref.watch(firestoreProvider);
      return FirestoreChallengeProgressRepository(firestore);
    });

/// Trip repository provider
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreTripRepository(firestore);
});
