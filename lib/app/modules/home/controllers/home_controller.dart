import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/home/data/ai_quiz_api.dart';
import 'package:quizkahoot/app/modules/home/data/ai_quiz_service.dart';
import 'package:quizkahoot/app/modules/home/models/generate_quiz_request.dart';
import 'package:quizkahoot/app/modules/home/data/game_api.dart';
import 'package:quizkahoot/app/modules/home/data/game_service.dart';
import 'package:quizkahoot/app/modules/home/models/create_game_request.dart';
import 'package:quizkahoot/app/modules/home/data/one_vs_one_room_api.dart';
import 'package:quizkahoot/app/modules/home/data/one_vs_one_room_service.dart';
import 'package:quizkahoot/app/modules/home/models/create_one_vs_one_room_request.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';
import 'package:quizkahoot/app/service/basecommon.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_plan_api.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_plan_service.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_purchase_api.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_purchase_service.dart';
import 'package:quizkahoot/app/modules/home/models/subscription_plan_model.dart';
import 'package:quizkahoot/app/modules/home/models/user_subscription_model.dart';
import 'package:quizkahoot/app/service/url_handler_service.dart';
import 'package:url_launcher/url_launcher.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  late PageController pageController;
  
  late AIQuizService aiQuizService;
  late QuizSetService quizSetService;
  late GameService gameService;
  late OneVsOneRoomService oneVsOneRoomService;
  late SubscriptionPlanService subscriptionPlanService;
  late SubscriptionPurchaseService subscriptionPurchaseService;
  var isLoading = false.obs;
  var isLoadingMyQuiz = false.obs;
  var isLoadingGame = false.obs;
  var myQuizSets = <QuizSetModel>[].obs;
  
  // Subscription plans
  var subscriptionPlans = <SubscriptionPlanModel>[].obs;
  var isLoadingPlans = false.obs;
  var isPurchasing = false.obs;
  var userSubscription = Rxn<UserSubscriptionModel>();
  var isLoadingSubscription = false.obs;
  var activeSubscriptionPlan = Rxn<SubscriptionPlanModel>();

  // AI Quiz Dialog state
  var selectedPart = 'Part 1 – Photographs'.obs;
  var selectedDifficulty = '100–300 – Sơ cấp (Beginner)'.obs;
  var topicContent = ''.obs;
  var questionCount = ''.obs;

  // Navigation items
  final List<NavigationItem> navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Trang chủ',
    ),
    NavigationItem(
      icon: Icons.quiz_outlined,
      activeIcon: Icons.quiz,
      label: 'Quiz của tôi',
    ),
    NavigationItem(
      icon: Icons.event_outlined,
      activeIcon: Icons.event,
      label: 'Sự kiện',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Tài khoản',
    ),
  ];

  // Part options
  final List<String> partOptions = [
    'Part 1 – Photographs',
    'Part 2 – Question-Response',
    'Part 3 – Conversations',
    'Part 4 – Talks',
    'Part 5 – Incomplete Sentences',
    'Part 6 – Text Completion',
    'Part 7 – Reading Comprehension',
  ];

  // Difficulty options (ranges with labels)
  final List<String> difficultyOptions = [
    '100–300 – Sơ cấp (Beginner)',
    '305–450 – Cơ bản (Elementary)',
    '455–650 – Trung cấp (Intermediate)',
    '655–785 – Trung cao cấp (Upper-Intermediate)',
    '790–900 – Cao cấp (Advanced)',
    '905–990 – Thành thạo (Proficient)',
  ];

  @override
  void onInit() {
    pageController = PageController();
    _initializeAIService();
    _initializeQuizSetService();
    _initializeGameService();
    _initializeOneVsOneRoomService();
    _initializeSubscriptionPlanService();
    // loadSubscriptionPlans();
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void _initializeAIService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    aiQuizService = AIQuizService(
      aiQuizApi: AIQuizApi(dio, baseUrl: baseUrl),
    );
  }

  void _initializeQuizSetService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizSetService = QuizSetService(
      quizSetApi: QuizSetApi(dio, baseUrl: baseUrl),
    );
  }

  void _initializeGameService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    gameService = GameService(
      gameApi: GameApi(dio, baseUrl: baseUrl),
    );
  }

  void _initializeOneVsOneRoomService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    oneVsOneRoomService = OneVsOneRoomService(
      oneVsOneRoomApi: OneVsOneRoomApi(dio, baseUrl: baseUrl),
    );
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

  void changeTabIndex(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    // Load My Quiz and check subscription when switching to My Quiz tab
    if (index == 1) {
      loadMyQuizSets();
      checkUserSubscription();
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    // Load My Quiz and check subscription when switching to My Quiz tab
    if (index == 1) {
      loadMyQuizSets();
      checkUserSubscription();
    }
  }

  Future<void> loadMyQuizSets() async {
    try {
      final userId = BaseCommon.instance.userId;
      if (userId.isEmpty) {
        log('User ID is empty, cannot load my quiz sets');
        return;
      }

      isLoadingMyQuiz.value = true;
      final response = await quizSetService.getQuizSetsByCreator(userId);
      isLoadingMyQuiz.value = false;

      if (response.isSuccess && response.data != null) {
        myQuizSets.value = response.data!;
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoadingMyQuiz.value = false;
      log('Error loading my quiz sets: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi tải danh sách quiz',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void startQuiz(QuizSetModel quizSet) {
    // Navigate to Single Mode controller and start quiz
    Get.lazyPut<SingleModeController>(
      () => SingleModeController(),
    );
    final singleModeController = Get.find<SingleModeController>();
    singleModeController.startQuiz(quizSet.id);
  }

  Future<void> createGameRoom(QuizSetModel quizSet) async {
    try {
      final userId = BaseCommon.instance.userId;
      if (userId.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoadingGame.value = true;
      
      final request = CreateGameRequest(
        hostUserId: userId,
        hostUserName: 'string', // TODO: Get actual username from user info
        quizSetId: quizSet.id,
      );

      final response = await gameService.createGame(request);
      isLoadingGame.value = false;

      if (response.isSuccess && response.data != null) {
        // Navigate to game room page
        Get.toNamed('/game-room', arguments: response.data);
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoadingGame.value = false;
      log('Error creating game room: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi tạo phòng game',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Hiển thị dialog để chọn mode (1vs1 hoặc Multiplayer)
  void showOneVsOneModeDialog(QuizSetModel quizSet) {
    final context = Get.context;
    if (context == null) return;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextConstant.titleH2(
                context,
                text: "Chế độ chơi",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: UtilsReponsive.height(24, context)),
              
              // 1vs1 Option
              _buildModeOption(
                context,
                icon: Icons.person,
                title: "1 vs 1",
                description: "Đấu trực tiếp với 1 người chơi",
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  createOneVsOneRoom(quizSet, mode: 0);
                },
              ),
              
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // Multiplayer Option
              _buildModeOption(
                context,
                icon: Icons.people,
                title: "Multiplayer",
                description: "Nhiều người chơi cùng lúc (không giới hạn)",
                color: Colors.purple,
                onTap: () {
                  Get.back();
                  createOneVsOneRoom(quizSet, mode: 1);
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

  Widget _buildModeOption(
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
          padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: UtilsReponsive.height(24, context)),
              ),
              SizedBox(width: UtilsReponsive.width(16, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConstant.subTile1(
                      context,
                      text: title,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: UtilsReponsive.height(4, context)),
                    TextConstant.subTile3(
                      context,
                      text: description,
                      color: Colors.grey[600]!,
                      size: 12,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: UtilsReponsive.height(16, context)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createOneVsOneRoom(QuizSetModel quizSet, {int mode = 0}) async {
    try {
      final userId = BaseCommon.instance.userId;
      if (userId.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoadingGame.value = true;
      
      // TODO: Get actual username from user info
      final player1Name = 'Player1'; // Temporary, should get from user profile
      
      final request = CreateOneVsOneRoomRequest(
        player1Name: player1Name,
        quizSetId: quizSet.id,
        player1UserId: userId,
        mode: mode, // 0 = 1vs1, 1 = Multiplayer
      );

      final response = await oneVsOneRoomService.createRoom(request);
      isLoadingGame.value = false;

      if (response.isSuccess && response.data != null) {
        // Navigate to 1vs1 room page
        Get.toNamed('/one-vs-one-room', arguments: response.data);
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoadingGame.value = false;
      log('Error creating 1vs1 room: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi tạo phòng 1vs1',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void resetAIDialogForm() {
    selectedPart.value = 'Part 1 – Photographs';
    selectedDifficulty.value = '100–300 – Sơ cấp (Beginner)';
    topicContent.value = '';
    questionCount.value = '';
  }

  /// Extract range from difficulty label (e.g., "100–300 – Sơ cấp (Beginner)" -> "100-300")
  String _mapDifficultyToRange(String difficulty) {
    try {
      // Extract range from format "100–300 – Sơ cấp (Beginner)"
      // Match pattern: digits–digits
      final match = RegExp(r'(\d+)–(\d+)').firstMatch(difficulty);
      if (match != null && match.groupCount >= 2) {
        // Convert en dash (–) to hyphen (-)
        return '${match.group(1)}-${match.group(2)}';
      }
      // Fallback: try to find any range pattern
      final fallbackMatch = RegExp(r'(\d+)[–-](\d+)').firstMatch(difficulty);
      if (fallbackMatch != null && fallbackMatch.groupCount >= 2) {
        return '${fallbackMatch.group(1)}-${fallbackMatch.group(2)}';
      }
      // If no match, return original (should not happen)
      log('Warning: Could not extract range from difficulty: $difficulty');
      return difficulty;
    } catch (e) {
      log('Error extracting difficulty range: $e');
      return difficulty;
    }
  }

  /// Extract part number from "Part X – ..." string
  int _extractPartNumber(String partString) {
    try {
      // Extract number from "Part X – ..." format
      final match = RegExp(r'Part (\d+)').firstMatch(partString);
      if (match != null && match.groupCount >= 1) {
        return int.parse(match.group(1)!);
      }
      // Fallback: try to extract just the number
      final number = partString.replaceAll('Part ', '').split(' ').first.trim();
      return int.parse(number);
    } catch (e) {
      log('Error extracting part number: $e');
      return 1;
    }
  }

  /// Generate quiz using AI
  Future<void> generateQuizWithAI() async {
    try {
      // Validate inputs
      if (topicContent.value.trim().isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng nhập nội dung đề tài',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (questionCount.value.trim().isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng nhập số lượng câu hỏi',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final questionQuantity = int.tryParse(questionCount.value.trim());
      if (questionQuantity == null || questionQuantity <= 0) {
        Get.snackbar(
          'Lỗi',
          'Số lượng câu hỏi phải là số nguyên dương',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Get creator ID
      final creatorId = BaseCommon.instance.userId;
      if (creatorId.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;
      log('creatorId: $creatorId');
      // Prepare request
      final request = GenerateQuizRequest(
        questionQuantity: questionQuantity,
        difficulty: _mapDifficultyToRange(selectedDifficulty.value),
        topic: topicContent.value.trim(),
        creatorId: creatorId,
      );

      // Extract part number
      final partNumber = _extractPartNumber(selectedPart.value);

      // Call API
      final response = await aiQuizService.generateQuiz(partNumber, request);
      log('response: ${response.toString()}');

      isLoading.value = false;

      if (response.isSuccess) {
        Get.snackbar(
          'Thành công',
          'Tạo quiz thành công!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Reset form
        resetAIDialogForm();
        
        // Reload My Quiz list if we're on the My Quiz tab
        if (currentIndex.value == 1) {
          await loadMyQuizSets();
        }
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      log('Error in generateQuizWithAI: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi. Vui lòng thử lại.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void viewTournament() {
    // Navigate to tournament page
    Get.toNamed('/tournament');
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

  Future<void> checkUserSubscription() async {
    final userId = BaseCommon.instance.userId;
    if (userId.isEmpty) {
      // If no userId, load plans anyway
      await loadSubscriptionPlans();
      return;
    }

    isLoadingSubscription.value = true;
    try {
      final response = await subscriptionPlanService.getUserSubscription();
      if (response.isSuccess && response.data != null) {
        userSubscription.value = response.data!;
        
        // If subscription is active, load plan details
        if (response.data!.isActive) {
          log('User has active subscription, loading plan details');
          await _loadActiveSubscriptionPlan(response.data!.subscriptionPlanId);
          return;
        }
      }
      
      // If no subscription or expired, load plans
      await loadSubscriptionPlans();
    } catch (e) {
      log('Error checking user subscription: $e');
      // If error, load plans anyway
      await loadSubscriptionPlans();
    } finally {
      isLoadingSubscription.value = false;
    }
  }

  Future<void> _loadActiveSubscriptionPlan(String planId) async {
    try {
      // Load plans if not already loaded
      if (subscriptionPlans.isEmpty) {
        final response = await subscriptionPlanService.getSubscriptionPlans();
        if (response.isSuccess && response.data != null) {
          subscriptionPlans.value = response.data!;
        }
      }
      
      // Find the plan
      final plan = subscriptionPlans.firstWhere(
        (plan) => plan.id == planId,
        orElse: () => SubscriptionPlanModel(
          id: planId,
          name: 'Unknown Plan',
          price: 0,
          durationDays: 0,
          canAccessPremiumContent: false,
          canAccessAiFeatures: false,
          aiGenerateQuizSetMaxTimes: 0,
          isActive: true,
          createdAt: '',
        ),
      );
      activeSubscriptionPlan.value = plan;
    } catch (e) {
      log('Error loading active subscription plan: $e');
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
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
