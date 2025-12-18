import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_favorite_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_favorite_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';
import 'package:quizkahoot/app/modules/home/data/game_api.dart';
import 'package:quizkahoot/app/modules/home/data/game_service.dart';
import 'package:quizkahoot/app/modules/home/models/create_game_request.dart';
import 'package:quizkahoot/app/modules/home/data/one_vs_one_room_api.dart';
import 'package:quizkahoot/app/modules/home/data/one_vs_one_room_service.dart';
import 'package:quizkahoot/app/modules/home/models/create_one_vs_one_room_request.dart';
import 'package:quizkahoot/app/service/basecommon.dart';
import 'package:quizkahoot/app/resource/reponsive_utils.dart';
import 'package:quizkahoot/app/resource/text_style.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class ExploreQuizController extends GetxController {
  final quizSetService = QuizSetService(quizSetApi: QuizSetApi(Dio(), baseUrl: baseUrl));
  late GameService gameService;
  late OneVsOneRoomService oneVsOneRoomService;
  late UserQuizSetFavoriteService favoriteService;
  
  // Observable variables
  var isLoading = false.obs;
  var isLoadingFavorites = false.obs;
  var isLoadingGame = false.obs;
  var quizSets = <QuizSetModel>[].obs;
  var filteredQuizSets = <QuizSetModel>[].obs;
  var selectedFilter = 'All'.obs;
  var searchQuery = ''.obs;
  final favoriteQuizSetIds = <String>{}.obs; // Set of favorite quiz set IDs
  
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
    _initializeFavoriteService();
    _initializeGameService();
    _initializeOneVsOneRoomService();
    loadQuizSets();
    loadFavorites();
  }

  void _initializeDio() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizSetService.quizSetApi = QuizSetApi(dio, baseUrl: baseUrl);
  }

  void _initializeFavoriteService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    favoriteService = UserQuizSetFavoriteService(
      userQuizSetFavoriteApi: UserQuizSetFavoriteApi(dio, baseUrl: baseUrl),
    );
  }

  void _initializeGameService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    gameService = GameService(gameApi: GameApi(dio, baseUrl: baseUrl));
  }

  void _initializeOneVsOneRoomService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    oneVsOneRoomService = OneVsOneRoomService(
      oneVsOneRoomApi: OneVsOneRoomApi(dio, baseUrl: baseUrl),
    );
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


  Future<void> loadFavorites() async {
    try {
      final userId = BaseCommon.instance.userId;
      if (userId.isEmpty) {
        log("User ID is empty, cannot load favorites");
        return;
      }

      isLoadingFavorites.value = true;
      final response = await favoriteService.getUserFavorites(userId);
      isLoadingFavorites.value = false;

      if (response.isSuccess && response.data != null) {
        // Extract quiz set IDs from favorites
        favoriteQuizSetIds.clear();
        favoriteQuizSetIds.addAll(
          response.data!.map((favorite) => favorite.quizSetId),
        );
        log("Loaded ${favoriteQuizSetIds.length} favorite quiz sets");
      } else {
        log("Failed to load favorites: ${response.message}");
      }
    } catch (e) {
      isLoadingFavorites.value = false;
      log("Error loading favorites: $e");
    }
  }

  bool isFavorite(String quizSetId) {
    return favoriteQuizSetIds.contains(quizSetId);
  }

  Future<void> refreshQuizSets() async {
    await loadQuizSets();
    await loadFavorites();
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
