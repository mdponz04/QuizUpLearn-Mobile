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
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  late PageController pageController;
  
  late AIQuizService aiQuizService;
  late QuizSetService quizSetService;
  late GameService gameService;
  var isLoading = false.obs;
  var isLoadingMyQuiz = false.obs;
  var isLoadingGame = false.obs;
  var myQuizSets = <QuizSetModel>[].obs;

  // AI Quiz Dialog state
  var selectedPart = 'Part 1'.obs;
  var selectedDifficulty = '70-100'.obs;
  var topicContent = ''.obs;
  var questionCount = ''.obs;

  // Navigation items
  final List<NavigationItem> navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.quiz_outlined,
      activeIcon: Icons.quiz,
      label: 'My Quiz',
    ),
    NavigationItem(
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum,
      label: 'Forum',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Account',
    ),
  ];

  // Part options
  final List<String> partOptions = [
    'Part 1',
    'Part 2',
    'Part 3',
    'Part 4',
    'Part 5',
    'Part 6',
    'Part 7',
  ];

  // Difficulty options (ranges)
  final List<String> difficultyOptions = [
    '50-100',
    '60-100',
    '70-100',
    '80-100',
    '90-100',
  ];

  @override
  void onInit() {
    pageController = PageController();
    _initializeAIService();
    _initializeQuizSetService();
    _initializeGameService();
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

  void changeTabIndex(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    // Load My Quiz when switching to My Quiz tab
    if (index == 1) {
      loadMyQuizSets();
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    // Load My Quiz when switching to My Quiz tab
    if (index == 1) {
      loadMyQuizSets();
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

  void resetAIDialogForm() {
    selectedPart.value = 'Part 1';
    selectedDifficulty.value = '70-100';
    topicContent.value = '';
    questionCount.value = '';
  }

  /// Map difficulty to range format (already in range format, just return as is)
  String _mapDifficultyToRange(String difficulty) {
    // Difficulty is already in range format (e.g., "50-100", "70-100")
    return difficulty;
  }

  /// Extract part number from "Part X" string
  int _extractPartNumber(String partString) {
    try {
      final number = partString.replaceAll('Part ', '').trim();
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
