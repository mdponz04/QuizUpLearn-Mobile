import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';
import 'package:quizkahoot/app/resource/color_manager.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class ExploreQuizController extends GetxController {
  final quizSetService = QuizSetService(quizSetApi: QuizSetApi(Dio(), baseUrl: baseUrl));
  
  // Observable variables
  var isLoading = false.obs;
  var quizSets = <QuizSetModel>[].obs;
  var filteredQuizSets = <QuizSetModel>[].obs;
  var selectedFilter = 'All'.obs;
  var searchQuery = ''.obs;
  
  // Filter options
  final List<String> filterOptions = [
    'All',
    'TOEIC',
    'IELTS',
    'TOEFL',
    'Grammar',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    loadQuizSets();
  }

  void _initializeDio() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizSetService.quizSetApi = QuizSetApi(dio, baseUrl: baseUrl);
  }

  Future<void> loadQuizSets() async {
    try {
      isLoading.value = true;
      final response = await quizSetService.getQuizSets();
      
      if (response.isSuccess && response.data != null) {
        quizSets.value = response.data!;
        filteredQuizSets.value = response.data!;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("error load quiz sets: $e");
      Get.snackbar(
        'Error',
        'Failed to load quiz sets. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterQuizSets(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void searchQuizSets(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    List<QuizSetModel> filtered = List.from(quizSets);
    
    // Apply type filter
    if (selectedFilter.value != 'All') {
      filtered = filtered.where((quiz) => 
        quiz.quizType == int.parse(selectedFilter.value)
      ).toList();
    }
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((quiz) =>
        quiz.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        quiz.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        quiz.skillType.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    filteredQuizSets.value = filtered;
  }

  void startQuiz(QuizSetModel quizSet) {
    // Navigate to Single Mode controller and start quiz
    final singleModeController = Get.find<SingleModeController>();
    singleModeController.startQuiz(quizSet.id);
  }

  void showPlayGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextConstant.titleH2(
          context,
          text: "Chơi Game",
          color: ColorsManager.primary,
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.keyboard, color: ColorsManager.primary),
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
              leading: Icon(Icons.qr_code_scanner, color: ColorsManager.primary),
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
            child: TextConstant.subTile1(
              context,
              text: "Hủy",
              color: Colors.grey[600]!,
            ),
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
        title: TextConstant.titleH3(
          context,
          text: "Nhập mã PIN",
          color: Colors.black,
          fontWeight: FontWeight.bold,
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
            child: TextConstant.subTile1(
              context,
              text: "Hủy",
              color: Colors.grey[600]!,
            ),
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
              backgroundColor: ColorsManager.primary,
            ),
            child: TextConstant.subTile1(
              context,
              text: "Tham gia",
              color: Colors.white,
              fontWeight: FontWeight.bold,
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

  Future<void> refreshQuizSets() async {
    await loadQuizSets();
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  // Get difficulty color
  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Get quiz type icon
  String getQuizTypeIcon(String quizType) {
    switch (quizType.toUpperCase()) {
      case 'TOEIC':
        return '🎧';
      case 'IELTS':
        return '📚';
      case 'TOEFL':
        return '🌍';
      case 'GRAMMAR':
        return '📝';
      default:
        return '📖';
    }
  }
}
