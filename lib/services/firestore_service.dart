import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_data.dart';

class FirestoreService {
  FirestoreService(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<UserData> streamUser(String uid) {
    return _users.doc(uid).snapshots().map(UserData.fromDoc);
  }

  Future<void> upsertUser(
    User user, {
    Locale? locale,
    bool? darkMode,
  }) {
    final doc = _users.doc(user.uid);
    final data = <String, dynamic>{
      'name': user.displayName,
      'email': user.email,
    };
    if (locale != null) {
      data['locale'] = locale.languageCode;
    }
    if (darkMode != null) {
      data['darkMode'] = darkMode;
    }
    return doc.set(data, SetOptions(merge: true));
  }
}