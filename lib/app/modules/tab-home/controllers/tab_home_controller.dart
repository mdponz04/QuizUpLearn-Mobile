import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_plan_api.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_plan_service.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_purchase_api.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_purchase_service.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_api.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_service.dart';
import 'package:quizkahoot/app/modules/home/models/subscription_plan_model.dart';
import 'package:quizkahoot/app/modules/home/models/dashboard_models.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import 'package:quizkahoot/app/service/basecommon.dart';
import 'package:quizkahoot/app/service/url_handler_service.dart';
import 'package:url_launcher/url_launcher.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class TabHomeController extends GetxController {
  // User progress data
  final currentLevel = 12.obs;
  final currentExp = 2450.obs;
  final maxExp = 3000.obs;
  final currentStreak = 7.obs;
  final totalBadges = 5.obs;
  final recentBadge = "Quiz Master".obs;

  // Subscription plans
  late SubscriptionPlanService subscriptionPlanService;
  late SubscriptionPurchaseService subscriptionPurchaseService;
  var subscriptionPlans = <SubscriptionPlanModel>[].obs;
  var isLoadingPlans = false.obs;
  var isPurchasing = false.obs;

  // Dashboard
  late DashboardService dashboardService;
  var dashboardData = Rxn<DashboardData>();
  var isLoadingDashboard = false.obs;

  // Quick action methods
  void startQuiz() {
    // Navigate to explore quiz page
    Get.toNamed('/explore-quiz');
  }

  void playGame() {
    _showGameModeDialog(Get.context!);
  }

  void _showGameModeDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
          constraints: BoxConstraints(
            maxWidth: UtilsReponsive.width(400, context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.videogame_asset,
                    color: ColorsManager.primary,
                    size: UtilsReponsive.height(28, context),
                  ),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  Expanded(
                    child: TextConstant.titleH3(
                      context,
                      text: "Chế độ chơi",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      size: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: UtilsReponsive.height(20, context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: UtilsReponsive.height(24, context)),
              
              // Multi Mode Option
              _buildGameModeOption(
                context,
                icon: Icons.people,
                title: "Multi Player(Quản trò)",
                description: "Nhiều người chơi cùng lúc\nNhập PIN hoặc quét QR để tham gia",
                color: Colors.purple,
                onTap: () {
                  Get.back();
                  _showMultiPlayerOptions(context);
                },
              ),
              
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // 1vs1 Mode Option
              _buildGameModeOption(
                context,
                icon: Icons.person,
                title: "1 vs 1",
                description: "Đấu trực tiếp với 1 người chơi\nNhập PIN hoặc quét QR để tham gia",
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  _showOneVsOneJoinDialog(context);
                },
              ),
              
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // Multi Player thường Option
              _buildGameModeOption(
                context,
                icon: Icons.people_outline,
                title: "Multi Player thường",
                description: "Nhiều người chơi cùng lúc\nNhập PIN hoặc quét QR để tham gia",
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  _showOneVsOneJoinDialog(context);
                },
              ),
              
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: UtilsReponsive.height(12, context),
                    ),
                  ),
                  child: TextConstant.subTile2(
                    context,
                    text: "Hủy",
                    color: Colors.grey[600]!,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(UtilsReponsive.width(4, context)),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: UtilsReponsive.height(24, context),
                ),
              ),
              SizedBox(width: UtilsReponsive.width(16, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConstant.subTile3(
                      context,
                      text: title,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: UtilsReponsive.height(4, context)),
                    // TextConstant.subTile4(
                    //   context,
                    //   text: description,
                    //   color: Colors.grey[600]!,
                    // ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: UtilsReponsive.height(16, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMultiPlayerOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextConstant.titleH2(
          context,
          text: "Tham gia Multi Player",
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.keyboard, color: Colors.purple),
              title: TextConstant.subTile1(
                context,
                text: "Nhập mã PIN",
                color: Colors.black,
              ),
              onTap: () {
                Get.back();
                _showEnterPinDialog(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.qr_code_scanner, color: Colors.purple),
              title: TextConstant.subTile1(
                context,
                text: "Quét QR Code",
                color: Colors.black,
              ),
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
            child: TextConstant.subTile2(
              context,
              text: "Hủy",
              color: Colors.grey[600]!,
            ),
          ),
        ],
      ),
    );
  }

  void _showOneVsOneJoinDialog(BuildContext context) {
    final pinController = TextEditingController();
    final playerNameController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
          constraints: BoxConstraints(
            maxWidth: UtilsReponsive.width(400, context),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.orange,
                      size: UtilsReponsive.height(28, context),
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    Expanded(
                      child: TextConstant.titleH2(
                        context,
                        text: "Tham gia 1 vs 1",
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: UtilsReponsive.height(20, context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Room PIN
                TextConstant.subTile1(
                  context,
                  text: "Room PIN",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextField(
                  controller: pinController,
                  decoration: InputDecoration(
                    hintText: "Nhập Room PIN",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.orange),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Player Name
                TextConstant.subTile1(
                  context,
                  text: "Tên người chơi",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextField(
                  controller: playerNameController,
                  decoration: InputDecoration(
                    hintText: "Nhập tên của bạn",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.orange),
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(24, context)),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: UtilsReponsive.height(12, context),
                          ),
                        ),
                        child: TextConstant.subTile2(
                          context,
                          text: "Hủy",
                          color: Colors.grey[600]!,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: UtilsReponsive.width(12, context)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final pin = pinController.text.trim();
                          final playerName = playerNameController.text.trim();
                          if (pin.isNotEmpty && playerName.isNotEmpty) {
                            Get.back();
                            _joinOneVsOneRoom(pin, playerName);
                          } else {
                            Get.snackbar(
                              'Lỗi',
                              'Vui lòng nhập đầy đủ thông tin',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: UtilsReponsive.height(12, context),
                          ),
                        ),
                        child: TextConstant.subTile2(
                          context,
                          text: "Tham gia",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _joinOneVsOneRoom(String roomPin, String playerName) {
    // Navigate to 1vs1 room view với thông tin Player2
    Get.toNamed('/one-vs-one-room', arguments: {
      'roomPin': roomPin,
      'playerName': playerName,
      'isPlayer1': false,
    });
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

  void viewTournament() {
    // Navigate to tournament page
    Get.toNamed('/tournament');
  }

  void viewQuizHistory() {
    // Navigate to quiz history page
    Get.toNamed('/quiz-history');
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
    _initializeSubscriptionPlanService();
    _initializeDashboardService();
    loadSubscriptionPlans();
    loadDashboard();
  }

  void _initializeSubscriptionPlanService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    subscriptionPlanService = SubscriptionPlanService(
      subscriptionPlanApi: SubscriptionPlanApi(dio, baseUrl: baseUrl),
    );
    subscriptionPurchaseService = SubscriptionPurchaseService(
      subscriptionPurchaseApi: SubscriptionPurchaseApi(dio, baseUrl: baseUrl),
    );
  }

  void _initializeDashboardService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    dashboardService = DashboardService(
      dashboardApi: DashboardApi(dio, baseUrl: baseUrl),
    );
  }

  Future<void> loadDashboard() async {
    try {
      isLoadingDashboard.value = true;
      final response = await dashboardService.getDashboard();
      if (response.isSuccess && response.data != null) {
        dashboardData.value = response.data;
      } else {
        log('Failed to load dashboard: ${response.message}');
      }
    } catch (e) {
      log('Error loading dashboard: $e');
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  Future<void> purchaseSubscription(SubscriptionPlanModel plan) async {
    final userId = BaseCommon.instance.userId;
    if (userId.isEmpty) {
      Get.snackbar(
        'Error',
        'Please login to purchase subscription',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isPurchasing.value = true;
    try {
      final successUrl = UrlHandlerService.createPaymentSuccessUrl(
        planId: plan.id,
      );
      final cancelUrl = UrlHandlerService.createPaymentCancelUrl(
        planId: plan.id,
      );

      final response = await subscriptionPurchaseService.purchaseSubscription(
        userId: userId,
        planId: plan.id,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

      if (response.isSuccess && response.data != null) {
        // Open payment URL
        final paymentUrl = Uri.parse(response.data!.qrCodeUrl);
        if (await canLaunchUrl(paymentUrl)) {
          await launchUrl(
            paymentUrl,
            mode: LaunchMode.externalApplication,
          );
        } else {
          Get.snackbar(
            'Error',
            'Cannot open payment link',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create payment link: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<void> loadSubscriptionPlans() async {
    isLoadingPlans.value = true;
    try {
      final response = await subscriptionPlanService.getSubscriptionPlans();
      if (response.isSuccess && response.data != null) {
        subscriptionPlans.value = response.data!;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load subscription plans',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingPlans.value = false;
    }
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
