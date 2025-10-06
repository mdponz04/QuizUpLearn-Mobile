import 'package:get/get.dart';
import '../models/badge_model.dart';
import '../data/badge_data.dart';

class BadgeController extends GetxController {
  // Badge data
  final allBadges = <BadgeModel>[].obs;
  final selectedType = BadgeType.quiz.obs;
  final searchQuery = ''.obs;
  final showOnlyUnlocked = false.obs;

  // Statistics
  final totalBadges = 0.obs;
  final unlockedBadges = 0.obs;
  final totalPoints = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadBadges();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void loadBadges() {
    allBadges.value = BadgeData.getAllBadges();
    updateStatistics();
  }

  void updateStatistics() {
    totalBadges.value = BadgeData.getTotalBadges();
    unlockedBadges.value = BadgeData.getUnlockedCount();
    totalPoints.value = BadgeData.getTotalPoints();
  }

  void setSelectedType(BadgeType type) {
    selectedType.value = type;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void toggleShowOnlyUnlocked() {
    showOnlyUnlocked.value = !showOnlyUnlocked.value;
  }

  List<BadgeModel> get filteredBadges {
    List<BadgeModel> badges = allBadges;

    // Filter by type
    if (selectedType.value != BadgeType.quiz) {
      badges = badges.where((badge) => badge.type == selectedType.value).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      badges = badges.where((badge) =>
          badge.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          badge.description.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }

    // Filter by unlocked status
    if (showOnlyUnlocked.value) {
      badges = badges.where((badge) => badge.isUnlocked).toList();
    }

    // Sort: unlocked first, then by rarity, then by name
    badges.sort((a, b) {
      if (a.isUnlocked != b.isUnlocked) {
        return a.isUnlocked ? -1 : 1;
      }
      if (a.rarity != b.rarity) {
        return b.rarity.index.compareTo(a.rarity.index);
      }
      return a.name.compareTo(b.name);
    });

    return badges;
  }

  List<BadgeModel> getBadgesByType(BadgeType type) {
    return allBadges.where((badge) => badge.type == type).toList();
  }

  int getUnlockedCountByType(BadgeType type) {
    return getBadgesByType(type).where((badge) => badge.isUnlocked).length;
  }

  double getProgressByType(BadgeType type) {
    final badges = getBadgesByType(type);
    if (badges.isEmpty) return 0.0;
    return getUnlockedCountByType(type) / badges.length;
  }

  List<BadgeType> get allTypes => BadgeType.values;

  String get progressText {
    return '${unlockedBadges.value}/${totalBadges.value} badges unlocked';
  }

  double get overallProgress {
    if (totalBadges.value == 0) return 0.0;
    return unlockedBadges.value / totalBadges.value;
  }
}
