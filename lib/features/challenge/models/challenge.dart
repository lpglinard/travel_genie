class Challenge {
  const Challenge({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.goal,
    required this.type,
    required this.isActive,
    required this.endDate,
    required this.displayOrder,
    required this.rewardType,
    required this.rewardValue,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final int goal;
  final String type;
  final bool isActive;
  final int endDate;
  final int displayOrder;
  final String rewardType;
  final String rewardValue;

  factory Challenge.fromFirestore(Map<String, dynamic> data) {
    return Challenge(
      id: data['id'] as String? ?? '',
      titleKey: data['titleKey'] as String? ?? '',
      descriptionKey: data['descriptionKey'] as String? ?? '',
      goal: data['goal'] as int? ?? 1,
      type: data['type'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      endDate: data['endDate'] as int? ?? 9999999999999,
      displayOrder: data['displayOrder'] as int? ?? 1,
      rewardType: data['rewardType'] as String? ?? 'badge',
      rewardValue: data['rewardValue'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
      'goal': goal,
      'type': type,
      'isActive': isActive,
      'endDate': endDate,
      'displayOrder': displayOrder,
      'rewardType': rewardType,
      'rewardValue': rewardValue,
    };
  }

  Challenge copyWith({
    String? id,
    String? titleKey,
    String? descriptionKey,
    int? goal,
    String? type,
    bool? isActive,
    int? endDate,
    int? displayOrder,
    String? rewardType,
    String? rewardValue,
  }) {
    return Challenge(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      goal: goal ?? this.goal,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      endDate: endDate ?? this.endDate,
      displayOrder: displayOrder ?? this.displayOrder,
      rewardType: rewardType ?? this.rewardType,
      rewardValue: rewardValue ?? this.rewardValue,
    );
  }

  bool get isExpired =>
      DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(endDate));

  Duration get timeRemaining => isExpired
      ? Duration.zero
      : DateTime.fromMillisecondsSinceEpoch(endDate).difference(DateTime.now());

  // Helper getters for backward compatibility with UI components
  String get title =>
      titleKey; // UI components can use localization to resolve this
  String get description =>
      descriptionKey; // UI components can use localization to resolve this
}
