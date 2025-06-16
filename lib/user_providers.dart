import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final userDataProvider = StreamProvider<UserData?>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return FirebaseAuth.instance
      .authStateChanges()
      .asyncExpand((user) =>
          user == null ? const Stream.empty() : service.streamUser(user.uid));
});

final localeProvider = StateProvider<Locale?>((ref) => null);

final themeModeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.light);


