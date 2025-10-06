class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final BadgeType type;
  final BadgeRarity rarity;
  final int requiredValue;
  final String condition;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int points;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.rarity,
    required this.requiredValue,
    required this.condition,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.points,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconPath: json['iconPath'],
      type: BadgeType.values.firstWhere((e) => e.name == json['type']),
      rarity: BadgeRarity.values.firstWhere((e) => e.name == json['rarity']),
      requiredValue: json['requiredValue'],
      condition: json['condition'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      points: json['points'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'type': type.name,
      'rarity': rarity.name,
      'requiredValue': requiredValue,
      'condition': condition,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'points': points,
    };
  }
}

enum BadgeType {
  quiz,
  streak,
  level,
  vocabulary,
  practice,
  social,
  special,
}

enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}

extension BadgeRarityExtension on BadgeRarity {
  String get displayName {
    switch (this) {
      case BadgeRarity.common:
        return 'Common';
      case BadgeRarity.rare:
        return 'Rare';
      case BadgeRarity.epic:
        return 'Epic';
      case BadgeRarity.legendary:
        return 'Legendary';
    }
  }

  String get color {
    switch (this) {
      case BadgeRarity.common:
        return '#9CA3AF'; // Gray
      case BadgeRarity.rare:
        return '#3B82F6'; // Blue
      case BadgeRarity.epic:
        return '#8B5CF6'; // Purple
      case BadgeRarity.legendary:
        return '#F59E0B'; // Gold
    }
  }
}

extension BadgeTypeExtension on BadgeType {
  String get displayName {
    switch (this) {
      case BadgeType.quiz:
        return 'Quiz';
      case BadgeType.streak:
        return 'Streak';
      case BadgeType.level:
        return 'Level';
      case BadgeType.vocabulary:
        return 'Vocabulary';
      case BadgeType.practice:
        return 'Practice';
      case BadgeType.social:
        return 'Social';
      case BadgeType.special:
        return 'Special';
    }
  }
}
