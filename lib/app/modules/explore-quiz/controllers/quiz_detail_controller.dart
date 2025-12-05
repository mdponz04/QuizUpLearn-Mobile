import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_model.dart';
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
import 'package:quizkahoot/app/resource/color_manager.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class QuizDetailController extends GetxController {
  late QuizSetService quizSetService;
  late GameService gameService;
  late OneVsOneRoomService oneVsOneRoomService;
  
  // Observable variables
  var isLoading = false.obs;
  var isLoadingGame = false.obs;
  var quizSet = Rxn<QuizSetModel>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    _initializeGameService();
    _initializeOneVsOneRoomService();
    
    // Get quiz set ID from arguments
    final quizSetId = Get.arguments as String?;
    if (quizSetId != null) {
      loadQuizSetDetail(quizSetId);
    }
  }

  void _initializeDio() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizSetService = QuizSetService(quizSetApi: QuizSetApi(dio, baseUrl: baseUrl));
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

  Future<void> loadQuizSetDetail(String quizSetId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await quizSetService.getQuizSetDetail(quizSetId);
      
      if (response.isSuccess && response.data != null) {
        quizSet.value = response.data;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("Error loading quiz set detail: $e");
      errorMessage.value = 'Failed to load quiz set detail. Please try again.';
      Get.snackbar(
        'Error',
        'Failed to load quiz set detail. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get quizzes without correct answers
  List<QuizModel> get quizzesWithoutAnswers {
    if (quizSet.value == null) return [];
    
    return quizSet.value!.quizzes.map((quiz) {
      // Create a copy of quiz with answer options that don't show isCorrect
      return quiz;
    }).toList();
  }

  void startQuiz() {
    if (quizSet.value == null) return;
    // Navigate to Single Mode controller and start quiz
    final singleModeController = Get.find<SingleModeController>();
    singleModeController.startQuiz(quizSet.value!.id);
  }

  Future<void> createGameRoom() async {
    if (quizSet.value == null) return;
    
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
        quizSetId: quizSet.value!.id,
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

  Future<void> createOneVsOneRoom({int mode = 0}) async {
    if (quizSet.value == null) return;
    
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
        quizSetId: quizSet.value!.id,
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

  void showGameModeDialog(BuildContext context) {
    if (quizSet.value == null) return;
    
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
                    child: TextConstant.titleH2(
                      context,
                      text: "Chế độ chơi",
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
              
              // Multi Player (Quản trò) Option
              _buildGameModeOption(
                context,
                icon: Icons.people,
                title: "Quản trò",
                description: "Nhiều người chơi cùng lúc\nHost tạo phòng, players join bằng PIN",
                color: Colors.purple,
                onTap: () {
                  Get.back();
                  createGameRoom();
                },
              ),
              
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // 1 vs 1 Option
              _buildGameModeOption(
                context,
                icon: Icons.person,
                title: "1 vs 1",
                description: "Đấu trực tiếp với 1 người chơi",
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  createOneVsOneRoom(mode: 0);
                },
              ),
              
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // Multiplayer Option
              _buildGameModeOption(
                context,
                icon: Icons.people_outline,
                title: "Multiplayer",
                description: "Nhiều người chơi cùng lúc (không giới hạn)",
                color: Colors.purple,
                onTap: () {
                  Get.back();
                  createOneVsOneRoom(mode: 1);
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
          padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
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
                padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
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
                    TextConstant.titleH3(
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
                      size: 11,
                    ),
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
}

