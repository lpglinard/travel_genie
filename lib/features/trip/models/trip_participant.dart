import 'package:cloud_firestore/cloud_firestore.dart';

enum ParticipantRole { organizer, participant }

class TripParticipant {
  const TripParticipant({
    required this.userId,
    required this.role,
    this.name,
    this.email,
    this.avatarUrl,
    this.joinedAt,
  });

  final String userId;
  final ParticipantRole role;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final DateTime? joinedAt;

  factory TripParticipant.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return TripParticipant(
      userId: doc.id,
      role: _parseRole(data['role'] as String?),
      name: data['name'] as String?,
      email: data['email'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory TripParticipant.fromMap(Map<String, dynamic> data, String userId) {
    return TripParticipant(
      userId: userId,
      role: _parseRole(data['role'] as String?),
      name: data['name'] as String?,
      email: data['email'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
    );
  }

  static ParticipantRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'organizer':
        return ParticipantRole.organizer;
      case 'participant':
      default:
        return ParticipantRole.participant;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role.name,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'joinedAt': joinedAt != null ? Timestamp.fromDate(joinedAt!) : null,
    };
  }

  TripParticipant copyWith({
    String? userId,
    ParticipantRole? role,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? joinedAt,
  }) {
    return TripParticipant(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  bool get isOrganizer => role == ParticipantRole.organizer;

  String get displayName => name ?? email ?? 'Unknown User';
}
