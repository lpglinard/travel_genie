import 'package:cloud_firestore/cloud_firestore.dart';

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
