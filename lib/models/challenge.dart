class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.targetValue,
    required this.rewardType,
    required this.rewardValue,
    this.isActive = true,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final DateTime startDate;
  final DateTime endDate;
  final int targetValue;
  final RewardType rewardType;
  final String rewardValue;
  final bool isActive;
  final int currentProgress;
  final bool isCompleted;
  final DateTime? completedAt;

  factory Challenge.fromFirestore(Map<String, dynamic> data) {
    return Challenge(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: ChallengeType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ChallengeType.createTrips,
      ),
      startDate: data['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['startDate'] as int)
          : DateTime.now(),
      endDate: data['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['endDate'] as int)
          : DateTime.now().add(const Duration(days: 7)),
      targetValue: data['targetValue'] as int? ?? 1,
      rewardType: RewardType.values.firstWhere(
        (e) => e.name == data['rewardType'],
        orElse: () => RewardType.badge,
      ),
      rewardValue: data['rewardValue'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      currentProgress: data['currentProgress'] as int? ?? 0,
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: data['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['completedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'targetValue': targetValue,
      'rewardType': rewardType.name,
      'rewardValue': rewardValue,
      'isActive': isActive,
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? targetValue,
    RewardType? rewardType,
    String? rewardValue,
    bool? isActive,
    int? currentProgress,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetValue: targetValue ?? this.targetValue,
      rewardType: rewardType ?? this.rewardType,
      rewardValue: rewardValue ?? this.rewardValue,
      isActive: isActive ?? this.isActive,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  double get progressPercentage =>
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  bool get isExpired => DateTime.now().isAfter(endDate);

  Duration get timeRemaining =>
      isExpired ? Duration.zero : endDate.difference(DateTime.now());

  String get timeRemainingText {
    if (isExpired) return 'Expirado';
    if (isCompleted) return 'Concluído';

    final remaining = timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays} dias restantes';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} horas restantes';
    } else {
      return '${remaining.inMinutes} minutos restantes';
    }
  }
}

enum ChallengeType {
  createTrips,
  addPlaces,
  inviteFriends,
  generateCovers,
  completeItinerary,
}

extension ChallengeTypeExtension on ChallengeType {
  String get displayName {
    switch (this) {
      case ChallengeType.createTrips:
        return 'Criar Viagens';
      case ChallengeType.addPlaces:
        return 'Adicionar Locais';
      case ChallengeType.inviteFriends:
        return 'Convidar Amigos';
      case ChallengeType.generateCovers:
        return 'Gerar Capas';
      case ChallengeType.completeItinerary:
        return 'Completar Roteiro';
    }
  }

  String get iconName {
    switch (this) {
      case ChallengeType.createTrips:
        return 'add_location';
      case ChallengeType.addPlaces:
        return 'place';
      case ChallengeType.inviteFriends:
        return 'group_add';
      case ChallengeType.generateCovers:
        return 'auto_awesome';
      case ChallengeType.completeItinerary:
        return 'checklist';
    }
  }
}

enum RewardType { badge, travelCover, points }

extension RewardTypeExtension on RewardType {
  String get displayName {
    switch (this) {
      case RewardType.badge:
        return 'Conquista';
      case RewardType.travelCover:
        return 'Capa de Viagem';
      case RewardType.points:
        return 'Pontos';
    }
  }
}

// Predefined challenges based on the requirements
class PredefinedChallenges {
  static List<Challenge> getWeeklyChallenges() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return [
      Challenge(
        id: 'weekly_trip_creator',
        title: 'Criador de Aventuras',
        description:
            'Crie uma viagem com pelo menos 5 locais para desbloquear uma capa personalizada surpresa!',
        type: ChallengeType.addPlaces,
        startDate: weekStart,
        endDate: weekEnd,
        targetValue: 5,
        rewardType: RewardType.travelCover,
        rewardValue: 'surprise_cover',
      ),
      Challenge(
        id: 'weekly_social_explorer',
        title: 'Explorador Social',
        description: 'Convide 2 amigos para colaborar em suas viagens',
        type: ChallengeType.inviteFriends,
        startDate: weekStart,
        endDate: weekEnd,
        targetValue: 2,
        rewardType: RewardType.badge,
        rewardValue: 'social_explorer',
      ),
    ];
  }

  static List<Challenge> getMonthlyChallenges() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    return [
      Challenge(
        id: 'monthly_trip_master',
        title: 'Mestre das Viagens',
        description: 'Crie 3 viagens completas este mês',
        type: ChallengeType.createTrips,
        startDate: monthStart,
        endDate: monthEnd,
        targetValue: 3,
        rewardType: RewardType.badge,
        rewardValue: 'trip_master',
      ),
      Challenge(
        id: 'monthly_cover_collector',
        title: 'Colecionador de Capas',
        description: 'Gere 10 capas personalizadas com diferentes estilos',
        type: ChallengeType.generateCovers,
        startDate: monthStart,
        endDate: monthEnd,
        targetValue: 10,
        rewardType: RewardType.travelCover,
        rewardValue: 'exclusive_style_pack',
      ),
    ];
  }
}
