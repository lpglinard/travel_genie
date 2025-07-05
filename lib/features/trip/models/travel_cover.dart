import 'cover_style.dart';

class TravelCover {
  const TravelCover({
    required this.id,
    required this.tripId,
    required this.imageUrl,
    required this.style,
    required this.createdAt,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  final String id;
  final String tripId;
  final String imageUrl;
  final CoverStyle style;
  final DateTime createdAt;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  factory TravelCover.fromFirestore(Map<String, dynamic> data) {
    return TravelCover(
      id: data['id'] as String? ?? '',
      tripId: data['tripId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      style: CoverStyle.values.firstWhere(
        (e) => e.name == data['style'],
        orElse: () => CoverStyle.impressionist,
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : DateTime.now(),
      isUnlocked: data['isUnlocked'] as bool? ?? false,
      unlockedAt: data['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['unlockedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tripId': tripId,
      'imageUrl': imageUrl,
      'style': style.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  TravelCover copyWith({
    String? id,
    String? tripId,
    String? imageUrl,
    CoverStyle? style,
    DateTime? createdAt,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return TravelCover(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      imageUrl: imageUrl ?? this.imageUrl,
      style: style ?? this.style,
      createdAt: createdAt ?? this.createdAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}