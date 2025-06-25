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

enum CoverStyle {
  impressionist,
  watercolor,
  surrealism,
  vintage,
  glassaic,
  vectorial,
  paperCut,
  childish,
  mattePainting,
  embroidery,
}

extension CoverStyleExtension on CoverStyle {
  String get displayName {
    switch (this) {
      case CoverStyle.impressionist:
        return 'Impressionista';
      case CoverStyle.watercolor:
        return 'Aquarela';
      case CoverStyle.surrealism:
        return 'Surrealismo';
      case CoverStyle.vintage:
        return 'Vintage';
      case CoverStyle.glassaic:
        return 'Mosaico de Vidro';
      case CoverStyle.vectorial:
        return 'Vetorial';
      case CoverStyle.paperCut:
        return 'Papel Recortado';
      case CoverStyle.childish:
        return 'Infantil';
      case CoverStyle.mattePainting:
        return 'Matte Painting';
      case CoverStyle.embroidery:
        return 'Bordado';
    }
  }

  String get description {
    switch (this) {
      case CoverStyle.impressionist:
        return 'Estilo artístico com pinceladas visíveis e cores vibrantes';
      case CoverStyle.watercolor:
        return 'Efeito de aquarela com cores suaves e fluidas';
      case CoverStyle.surrealism:
        return 'Arte surrealista com elementos fantásticos';
      case CoverStyle.vintage:
        return 'Estilo retrô com cores desbotadas';
      case CoverStyle.glassaic:
        return 'Efeito de mosaico com peças de vidro colorido';
      case CoverStyle.vectorial:
        return 'Arte vetorial com formas geométricas limpas';
      case CoverStyle.paperCut:
        return 'Estilo de papel recortado em camadas';
      case CoverStyle.childish:
        return 'Arte infantil com traços simples e cores alegres';
      case CoverStyle.mattePainting:
        return 'Pintura digital cinematográfica';
      case CoverStyle.embroidery:
        return 'Efeito de bordado com texturas de linha';
    }
  }
}

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
        .map((coverData) => TravelCover.fromFirestore(coverData as Map<String, dynamic>))
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

  List<TravelCover> get unlockedCovers => covers.where((cover) => cover.isUnlocked).toList();
  
  List<TravelCover> get lockedCovers => covers.where((cover) => !cover.isUnlocked).toList();
  
  double get completionPercentage => covers.isEmpty ? 0.0 : (totalUnlocked / covers.length) * 100;
}