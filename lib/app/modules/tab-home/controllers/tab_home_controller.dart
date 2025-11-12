import 'package:flutter/material.dart';
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
    // Navigate to explore quiz page
    Get.toNamed('/explore-quiz');
  }

  void playGame() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text(
          "Chơi Game",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.keyboard, color: Colors.orange),
              title: Text("Nhập mã PIN"),
              onTap: () {
                Get.back();
                _showEnterPinDialog(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.qr_code_scanner, color: Colors.orange),
              title: Text("Quét QR Code"),
              onTap: () {
                Get.back();
                _showQRScanner(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Hủy"),
          ),
        ],
      ),
    );
  }

  void _showEnterPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Nhập mã PIN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: pinController,
          decoration: InputDecoration(
            hintText: "Nhập mã PIN",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.isNotEmpty) {
                Get.back();
                _joinGameWithPin(pin);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text(
              "Tham gia",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    Get.toNamed('/player-game-room', arguments: {'mode': 'scan'});
  }

  void _joinGameWithPin(String pin) {
    Get.toNamed('/player-game-room', arguments: {'gamePin': pin, 'mode': 'pin'});
  }

  void openPlacementTests() {
    // Navigate to placement tests page
    Get.toNamed('/placement-tests');
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
