import 'travel_cover.dart';

class TravelCoverCollection {
  const TravelCoverCollection({
    required this.userId,
    required this.covers,
    this.totalUnlocked = 0,
  });

  final String userId;
  final List<TravelCover> covers;
  final int totalUnlocked;

  factory TravelCoverCollection.fromFirestore(Map<String, dynamic> data) {
    final coversData = data['covers'] as List<dynamic>? ?? [];
    final covers = coversData
        .map(
          (coverData) =>
              TravelCover.fromFirestore(coverData as Map<String, dynamic>),
        )
        .toList();

    return TravelCoverCollection(
      userId: data['userId'] as String? ?? '',
      covers: covers,
      totalUnlocked: data['totalUnlocked'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'covers': covers.map((cover) => cover.toFirestore()).toList(),
      'totalUnlocked': totalUnlocked,
    };
  }

  TravelCoverCollection copyWith({
    String? userId,
    List<TravelCover>? covers,
    int? totalUnlocked,
  }) {
    return TravelCoverCollection(
      userId: userId ?? this.userId,
      covers: covers ?? this.covers,
      totalUnlocked: totalUnlocked ?? this.totalUnlocked,
    );
  }

  List<TravelCover> get unlockedCovers =>
      covers.where((cover) => cover.isUnlocked).toList();

  List<TravelCover> get lockedCovers =>
      covers.where((cover) => !cover.isUnlocked).toList();

  double get completionPercentage =>
      covers.isEmpty ? 0.0 : (totalUnlocked / covers.length) * 100;
}