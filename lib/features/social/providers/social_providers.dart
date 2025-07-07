

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/infrastructure_providers.dart';
import '../services/groups_service.dart';

/// Provider for groups service
final groupsServiceProvider = Provider<GroupsService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return GroupsService(firestoreService);
});

/// Provider for groups feedback
final groupsFeedbackProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final groupsService = ref.watch(groupsServiceProvider);
  return groupsService.streamGroupsFeedbackSummary();
});

/// Provider for user feedback
final userFeedbackProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final groupsService = ref.watch(groupsServiceProvider);
  return groupsService.streamUserFeedback();
});
