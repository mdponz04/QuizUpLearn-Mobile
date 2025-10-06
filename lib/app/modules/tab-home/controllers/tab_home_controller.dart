import 'package:get/get.dart';

class TabHomeController extends GetxController {
  // User progress data
  final currentLevel = 12.obs;
  final currentExp = 2450.obs;
  final maxExp = 3000.obs;
  final currentStreak = 7.obs;
  final totalBadges = 5.obs;
  final recentBadge = "Quiz Master".obs;

  // Quick action methods
  void startQuiz() {
    // TODO: Navigate to quiz selection
    Get.snackbar(
      "Coming Soon",
      "Quiz feature will be available soon!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void startPractice() {
    Get.toNamed('/play-event');
  }

  void openVocabulary() {
    // TODO: Navigate to vocabulary
    Get.snackbar(
      "Coming Soon",
      "Vocabulary feature will be available soon!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void viewProgress() {
    // TODO: Navigate to detailed progress
    Get.snackbar(
      "Coming Soon",
      "Detailed progress will be available soon!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showNotifications() {
    // TODO: Show notifications
    Get.snackbar(
      "Notifications",
      "No new notifications",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Calculate progress percentage
  double get progressPercentage => currentExp.value / maxExp.value;

  // Get formatted exp text
  String get formattedExp => "${currentExp.value}/${maxExp.value}";

  // Get formatted streak text
  String get formattedStreak => "${currentStreak.value}d";

  @override
  void onInit() {
    super.onInit();
    // Initialize any data loading here
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
