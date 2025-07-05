import 'badge_category.dart';

class Badge {
  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  final String id;
  final String name;
  final String description;
  final String iconName;
  final BadgeCategory category;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  factory Badge.fromFirestore(Map<String, dynamic> data) {
    return Badge(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? '',
      category: BadgeCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => BadgeCategory.general,
      ),
      isUnlocked: data['isUnlocked'] as bool? ?? false,
      unlockedAt: data['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['unlockedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'category': category.name,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    BadgeCategory? category,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}