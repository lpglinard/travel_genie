import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserData {
  UserData({
    required this.uid,
    this.name,
    this.email,
    this.locale,
    this.darkMode,
  });

  final String uid;
  final String? name;
  final String? email;
  final String? locale;
  final bool? darkMode;

  factory UserData.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserData(
      uid: doc.id,
      name: data['name'] as String?,
      email: data['email'] as String?,
      locale: data['locale'] as String?,
      darkMode: data['darkMode'] as bool?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'locale': locale,
        'darkMode': darkMode,
      };
}

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
