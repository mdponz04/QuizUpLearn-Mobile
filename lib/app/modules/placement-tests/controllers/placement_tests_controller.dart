import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';
import 'package:quizkahoot/app/modules/home/data/game_api.dart';
import 'package:quizkahoot/app/modules/home/data/game_service.dart';
import 'package:quizkahoot/app/modules/home/models/create_game_request.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class PlacementTestsController extends GetxController {
  final quizSetService = QuizSetService(quizSetApi: QuizSetApi(Dio(), baseUrl: baseUrl));
  late GameService gameService;
  
  // Observable variables
  var isLoading = false.obs;
  var isLoadingGame = false.obs;
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
    _initializeGameService();
    loadQuizSets();
  }

  void _initializeDio() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizSetService.quizSetApi = QuizSetApi(dio, baseUrl: baseUrl);
  }

  void _initializeGameService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    gameService = GameService(gameApi: GameApi(dio, baseUrl: baseUrl));
  }

  Future<void> loadQuizSets() async {
    try {
      isLoading.value = true;
      
      // Call API with filter for placement tests
      final requestBody = {
        "filters": {
          "quizSetType": "placement"
        }
      };
      
      final response = await quizSetService.searchQuizSets(requestBody);
      
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
    // Set isPlacement = true to use placement test submit endpoint
    final singleModeController = Get.find<SingleModeController>();
    singleModeController.startQuiz(quizSet.id, isPlacement: true);
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

