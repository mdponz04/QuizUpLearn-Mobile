import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/home/data/ai_quiz_api.dart';
import 'package:quizkahoot/app/modules/home/data/ai_quiz_service.dart';
import 'package:quizkahoot/app/modules/home/models/generate_quiz_request.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  late PageController pageController;
  
  late AIQuizService aiQuizService;
  var isLoading = false.obs;

  // AI Quiz Dialog state
  var selectedPart = 'Part 1'.obs;
  var selectedDifficulty = 'Dễ'.obs;
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

  // Difficulty options
  final List<String> difficultyOptions = [
    'Dễ',
    'Trung bình',
    'Khó',
  ];

  @override
  void onInit() {
    pageController = PageController();
    _initializeAIService();
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

  void changeTabIndex(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void resetAIDialogForm() {
    selectedPart.value = 'Part 1';
    selectedDifficulty.value = 'Dễ';
    topicContent.value = '';
    questionCount.value = '';
  }

  /// Map Vietnamese difficulty to English
  String _mapDifficultyToEnglish(String vietnameseDifficulty) {
    switch (vietnameseDifficulty) {
      case 'Dễ':
        return 'easy';
      case 'Trung bình':
        return 'medium';
      case 'Khó':
        return 'hard';
      default:
        return 'medium';
    }
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
        difficulty: _mapDifficultyToEnglish(selectedDifficulty.value),
        topic: topicContent.value.trim(),
        creatorId: creatorId,
      );

      // Extract part number
      final partNumber = _extractPartNumber(selectedPart.value);

      // Call API
      final response = await aiQuizService.generateQuiz(partNumber, request);

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
