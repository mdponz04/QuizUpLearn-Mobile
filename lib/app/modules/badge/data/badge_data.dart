import '../models/badge_model.dart';

class BadgeData {
  static List<BadgeModel> getAllBadges() {
    return [
      // Quiz Badges
      BadgeModel(
        id: 'quiz_first',
        name: 'First Quiz',
        description: 'Complete your first quiz',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.quiz,
        rarity: BadgeRarity.common,
        requiredValue: 1,
        condition: 'Complete 1 quiz',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
        points: 10,
      ),
      BadgeModel(
        id: 'quiz_master',
        name: 'Quiz Master',
        description: 'Complete 10 quizzes with perfect scores',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.quiz,
        rarity: BadgeRarity.rare,
        requiredValue: 10,
        condition: 'Complete 10 quizzes with 100% score',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        points: 50,
      ),
      BadgeModel(
        id: 'quiz_legend',
        name: 'Quiz Legend',
        description: 'Complete 50 quizzes',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.quiz,
        rarity: BadgeRarity.epic,
        requiredValue: 50,
        condition: 'Complete 50 quizzes',
        isUnlocked: false,
        points: 200,
      ),

      // Streak Badges
      BadgeModel(
        id: 'streak_3',
        name: 'Getting Started',
        description: 'Maintain a 3-day streak',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.streak,
        rarity: BadgeRarity.common,
        requiredValue: 3,
        condition: 'Maintain a 3-day learning streak',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
        points: 15,
      ),
      BadgeModel(
        id: 'streak_7',
        name: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.streak,
        rarity: BadgeRarity.rare,
        requiredValue: 7,
        condition: 'Maintain a 7-day learning streak',
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        points: 35,
      ),
      BadgeModel(
        id: 'streak_30',
        name: 'Month Master',
        description: 'Maintain a 30-day streak',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.streak,
        rarity: BadgeRarity.epic,
        requiredValue: 30,
        condition: 'Maintain a 30-day learning streak',
        isUnlocked: false,
        points: 150,
      ),

      // Level Badges
      BadgeModel(
        id: 'level_5',
        name: 'Rising Star',
        description: 'Reach level 5',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.level,
        rarity: BadgeRarity.common,
        requiredValue: 5,
        condition: 'Reach level 5',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
        points: 25,
      ),
      BadgeModel(
        id: 'level_10',
        name: 'Level Up',
        description: 'Reach level 10',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.level,
        rarity: BadgeRarity.rare,
        requiredValue: 10,
        condition: 'Reach level 10',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 3)),
        points: 75,
      ),
      BadgeModel(
        id: 'level_20',
        name: 'Expert',
        description: 'Reach level 20',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.level,
        rarity: BadgeRarity.epic,
        requiredValue: 20,
        condition: 'Reach level 20',
        isUnlocked: false,
        points: 300,
      ),

      // Vocabulary Badges
      BadgeModel(
        id: 'vocab_100',
        name: 'Word Collector',
        description: 'Learn 100 vocabulary words',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.vocabulary,
        rarity: BadgeRarity.common,
        requiredValue: 100,
        condition: 'Learn 100 vocabulary words',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
        points: 40,
      ),
      BadgeModel(
        id: 'vocab_500',
        name: 'Vocabulary Master',
        description: 'Learn 500 vocabulary words',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.vocabulary,
        rarity: BadgeRarity.rare,
        requiredValue: 500,
        condition: 'Learn 500 vocabulary words',
        isUnlocked: false,
        points: 100,
      ),

      // Practice Badges
      BadgeModel(
        id: 'practice_10',
        name: 'Practice Makes Perfect',
        description: ' practice sessions',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.practice,
        rarity: BadgeRarity.common,
        requiredValue: 10,
        condition: 'Complete 10 practice sessions',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 4)),
        points: 30,
      ),

      // Special Badges
      BadgeModel(
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Study before 7 AM',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.special,
        rarity: BadgeRarity.rare,
        requiredValue: 1,
        condition: 'Study before 7 AM',
        isUnlocked: false,
        points: 60,
      ),
      BadgeModel(
        id: 'night_owl',
        name: 'Night Owl',
        description: 'Study after 10 PM',
        iconPath: 'assets/images/trophy.png',
        type: BadgeType.special,
        rarity: BadgeRarity.rare,
        requiredValue: 1,
        condition: 'Study after 10 PM',
        isUnlocked: false,
        points: 60,
      ),
    ];
  }

  static List<BadgeModel> getBadgesByType(BadgeType type) {
    return getAllBadges().where((badge) => badge.type == type).toList();
  }

  static List<BadgeModel> getUnlockedBadges() {
    return getAllBadges().where((badge) => badge.isUnlocked).toList();
  }

  static List<BadgeModel> getLockedBadges() {
    return getAllBadges().where((badge) => !badge.isUnlocked).toList();
  }

  static int getTotalPoints() {
    return getUnlockedBadges().fold(0, (sum, badge) => sum + badge.points);
  }

  static int getTotalBadges() {
    return getAllBadges().length;
  }

  static int getUnlockedCount() {
    return getUnlockedBadges().length;
  }
}
