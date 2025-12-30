import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_comment_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_comment_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_favorite_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_favorite_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_like_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_like_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_report_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_report_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_comment_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/create_quiz_set_comment_request.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/update_quiz_set_request.dart';
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
  late QuizSetCommentService quizSetCommentService;
  late UserQuizSetFavoriteService favoriteService;
  late UserQuizSetLikeService likeService;
  late GameService gameService;
  late OneVsOneRoomService oneVsOneRoomService;
  late QuizReportService quizReportService;
  
  // Observable variables
  var isLoading = false.obs;
  var isLoadingComments = false.obs;
  var isCreatingComment = false.obs;
  var isTogglingFavorite = false.obs;
  var isTogglingLike = false.obs;
  var isLoadingGame = false.obs;
  var isUpdating = false.obs;
  var isSubmittingReport = false.obs;
  var quizSet = Rxn<QuizSetModel>();
  var comments = <QuizSetCommentModel>[].obs;
  var errorMessage = ''.obs;
  var commentsErrorMessage = ''.obs;
  var hasUpdated = false.obs; // Track if quiz was updated
  var isFavorite = false.obs; // Track if current quiz is favorite
  var isFavoriteChanged = false.obs; // Track if favorite was changed
  var isLiked = false.obs; // Track if current quiz is liked
  var likeCount = 0.obs; // Track like count
  var isLoadingLikeCount = false.obs; // Track loading state for like count
  
  // Check if current user owns this quiz set
  bool get isOwner {
    if (quizSet.value == null) return false;
    final userId = BaseCommon.instance.userId;
    return quizSet.value!.createdBy == userId;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    _initializeCommentService();
    _initializeFavoriteService();
    _initializeLikeService();
    _initializeGameService();
    _initializeOneVsOneRoomService();
    _initializeQuizReportService();
    
    // Reset update flag when initializing
    hasUpdated.value = false;
    
    // Get quiz set ID from arguments
    final quizSetId = Get.arguments as String?;
    if (quizSetId != null) {
      loadQuizSetDetail(quizSetId);
      loadComments(quizSetId);
      checkFavorite(quizSetId);
      checkLike(quizSetId);
      loadLikeCount(quizSetId);
    }
  }

  void _initializeDio() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizSetService = QuizSetService(quizSetApi: QuizSetApi(dio, baseUrl: baseUrl));
  }

  void _initializeCommentService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizSetCommentService = QuizSetCommentService(
      quizSetCommentApi: QuizSetCommentApi(dio, baseUrl: baseUrl),
    );
  }

  void _initializeFavoriteService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    favoriteService = UserQuizSetFavoriteService(
      userQuizSetFavoriteApi: UserQuizSetFavoriteApi(dio, baseUrl: baseUrl),
    );
  }

  void _initializeLikeService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    likeService = UserQuizSetLikeService(
      userQuizSetLikeApi: UserQuizSetLikeApi(dio, baseUrl: baseUrl),
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

  void _initializeQuizReportService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizReportService = QuizReportService(
      quizReportApi: QuizReportApi(dio, baseUrl: baseUrl),
    );
  }

  Future<void> loadQuizSetDetail(String quizSetId, {bool preserveUpdateFlag = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (!preserveUpdateFlag) {
        hasUpdated.value = false; // Reset update flag when loading (unless preserving)
      }
      
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

  Future<void> loadComments(String quizSetId) async {
    try {
      isLoadingComments.value = true;
      commentsErrorMessage.value = '';
      
      final response = await quizSetCommentService.getQuizSetComments(quizSetId);
      
      if (response.isSuccess && response.data != null) {
        comments.value = response.data!;
      } else {
        commentsErrorMessage.value = response.message;
      }
    } catch (e) {
      log("Error loading comments: $e");
      commentsErrorMessage.value = 'Failed to load comments. Please try again.';
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> createComment(String content) async {
    if (quizSet.value == null) return;
    
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

    if (content.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập nội dung đánh giá',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isCreatingComment.value = true;
      
      final request = CreateQuizSetCommentRequest(
        userId: userId,
        quizSetId: quizSet.value!.id,
        content: content.trim(),
      );

      final response = await quizSetCommentService.createComment(request);
      isCreatingComment.value = false;

      if (response.isSuccess) {
        Get.snackbar(
          'Thành công',
          'Đã gửi đánh giá thành công',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Reload comments
        await loadComments(quizSet.value!.id);
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isCreatingComment.value = false;
      log('Error creating comment: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi gửi đánh giá',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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

  Future<void> updateQuizSet({
    required String title,
    required String description,
    required bool isPublished,
  }) async {
    if (quizSet.value == null) return;
    
    final quizSetId = quizSet.value!.id;
    
    try {
      isUpdating.value = true;
      
      final request = UpdateQuizSetRequest(
        title: title,
        description: description,
        isPublished: isPublished,
        isPremiumOnly: quizSet.value!.isPremiumOnly, // Keep existing value
      );
      
      final response = await quizSetService.updateQuizSet(
        quizSetId,
        request,
      );
      
      if (response.isSuccess && response.data != null) {
        // Reload quiz detail to get full data including quizzes
        // Preserve update flag so we know to refresh parent list
        hasUpdated.value = true; // Mark as updated before reloading
        await loadQuizSetDetail(quizSetId, preserveUpdateFlag: true);
        isUpdating.value = false;
        
        Get.snackbar(
          'Thành công',
          'Đã cập nhật quiz thành công',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        isUpdating.value = false;
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isUpdating.value = false;
      log('Error updating quiz set: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi cập nhật quiz',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showEditDialog(BuildContext context) {
    if (quizSet.value == null) return;
    
    final titleController = TextEditingController(text: quizSet.value!.title);
    final descriptionController = TextEditingController(text: quizSet.value!.description);
    var isPublished = quizSet.value!.isPublished.obs;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
          constraints: BoxConstraints(
            maxWidth: UtilsReponsive.width(400, context),
            maxHeight: UtilsReponsive.height(600, context),
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
                      Icons.edit,
                      color: ColorsManager.primary,
                      size: UtilsReponsive.height(28, context),
                    ),
                    SizedBox(width: UtilsReponsive.width(8, context)),
                    Expanded(
                      child: TextConstant.titleH2(
                        context,
                        text: "Chỉnh sửa Quiz",
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
                
                // Title Field
                TextConstant.subTile1(
                  context,
                  text: "Tiêu đề",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Nhập tiêu đề quiz",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(16, context),
                      vertical: UtilsReponsive.height(12, context),
                    ),
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Description Field
                TextConstant.subTile1(
                  context,
                  text: "Mô tả",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Nhập mô tả quiz",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(16, context),
                      vertical: UtilsReponsive.height(12, context),
                    ),
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(16, context)),
                
                // Published Toggle
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: TextConstant.subTile1(
                        context,
                        text: "Xuất bản",
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: isPublished.value,
                      onChanged: (value) => isPublished.value = value,
                      activeColor: ColorsManager.primary,
                    ),
                  ],
                )),
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
                      flex: 2,
                      child: Obx(() => ElevatedButton(
                        onPressed: isUpdating.value
                            ? null
                            : () {
                                if (titleController.text.trim().isEmpty) {
                                  Get.snackbar(
                                    'Lỗi',
                                    'Vui lòng nhập tiêu đề',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                updateQuizSet(
                                  title: titleController.text.trim(),
                                  description: descriptionController.text.trim(),
                                  isPublished: isPublished.value,
                                );
                                Get.back();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: UtilsReponsive.height(12, context),
                          ),
                        ),
                        child: isUpdating.value
                            ? SizedBox(
                                height: UtilsReponsive.height(20, context),
                                width: UtilsReponsive.height(20, context),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : TextConstant.subTile2(
                                context,
                                text: "Lưu",
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      )),
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

  Future<void> checkFavorite(String quizSetId) async {
    try {
      final userId = BaseCommon.instance.userId;
      if (userId.isEmpty) {
        isFavorite.value = false;
        return;
      }

      final response = await favoriteService.getUserFavorites(userId);
      
      if (response.isSuccess && response.data != null) {
        final favoriteIds = response.data!
            .map((favorite) => favorite.quizSetId)
            .toSet();
        isFavorite.value = favoriteIds.contains(quizSetId);
      } else {
        isFavorite.value = false;
      }
    } catch (e) {
      log("Error checking favorite: $e");
      isFavorite.value = false;
    }
  }

  Future<void> checkLike(String quizSetId) async {
    try {
      final userId = BaseCommon.instance.userId;
      if (userId.isEmpty) {
        isLiked.value = false;
        return;
      }

      final response = await likeService.getUserLikes(userId);
      
      if (response.isSuccess && response.data != null) {
        final likeIds = response.data!
            .map((like) => like.quizSetId)
            .toSet();
        isLiked.value = likeIds.contains(quizSetId);
      } else {
        isLiked.value = false;
      }
    } catch (e) {
      log("Error checking like: $e");
      isLiked.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    if (quizSet.value == null) return;
    
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

    try {
      isTogglingFavorite.value = true;

      final response = await favoriteService.toggleFavorite(
        quizSet.value!.id,
        userId,
      );
      isTogglingFavorite.value = false;

      if (response.isSuccess) {
        // Toggle state (đảo ngược state hiện tại) vì BE đang lỗi và luôn trả về true
        isFavorite.value = !isFavorite.value;
        isFavoriteChanged.value = true;
        
        Get.snackbar(
          'Thành công',
          isFavorite.value 
              ? 'Đã thêm vào yêu thích' 
              : 'Đã xóa khỏi yêu thích',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isTogglingFavorite.value = false;
      log('Error toggling favorite: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi cập nhật yêu thích',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> toggleLike() async {
    if (quizSet.value == null) return;
    
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

    try {
      isTogglingLike.value = true;

      final response = await likeService.toggleLike(
        quizSet.value!.id,
        userId,
      );
      isTogglingLike.value = false;

      if (response.isSuccess) {
        // Toggle state (đảo ngược state hiện tại) vì BE đang lỗi và luôn trả về true
        final wasLiked = isLiked.value;
        isLiked.value = !isLiked.value;
        
        // Update like count based on toggle
        if (wasLiked) {
          // Unliked, decrease count
          if (likeCount.value > 0) {
            likeCount.value--;
          }
        } else {
          // Liked, increase count
          likeCount.value++;
        }
        
        Get.snackbar(
          'Thành công',
          isLiked.value 
              ? 'Đã thích quiz' 
              : 'Đã bỏ thích quiz',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isTogglingLike.value = false;
      log('Error toggling like: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi cập nhật like',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadLikeCount(String quizSetId) async {
    try {
      isLoadingLikeCount.value = true;
      final response = await likeService.getLikeCount(quizSetId);
      isLoadingLikeCount.value = false;

      if (response.isSuccess && response.data != null) {
        likeCount.value = response.data!;
      } else {
        log("Failed to load like count: ${response.message}");
        likeCount.value = 0;
      }
    } catch (e) {
      isLoadingLikeCount.value = false;
      log('Error loading like count: $e');
      likeCount.value = 0;
    }
  }

  Future<void> reportQuiz(String quizId, String description) async {
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

    if (description.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập mô tả báo cáo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmittingReport.value = true;
      
      // Report for specific quiz question (not quiz set)
      final response = await quizReportService.reportQuiz(
        userId: userId,
        quizId: quizId,
        description: description.trim(),
      );
      
      isSubmittingReport.value = false;

      if (response.isSuccess) {
        Get.snackbar(
          'Thành công',
          'Đã gửi báo cáo câu hỏi thành công',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isSubmittingReport.value = false;
      log('Error reporting quiz: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi gửi báo cáo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showReportDialog(BuildContext context, String quizId) {
    final descriptionController = TextEditingController();
    
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
                    Icons.report_problem,
                    color: Colors.red,
                    size: UtilsReponsive.height(28, context),
                  ),
                  SizedBox(width: UtilsReponsive.width(8, context)),
                  Expanded(
                    child: TextConstant.subTile1(
                      context,
                      text: "Báo cáo câu hỏi",
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
              SizedBox(height: UtilsReponsive.height(16, context)),
              
              // Description Field
              TextConstant.subTile2(
                context,
                text: "Mô tả vấn đề",
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: UtilsReponsive.height(8, context)),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Nhập mô tả về vấn đề bạn gặp phải...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.all(UtilsReponsive.width(12, context)),
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
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                      onPressed: isSubmittingReport.value
                          ? null
                          : () {
                              final description = descriptionController.text.trim();
                              if (description.isEmpty) {
                                Get.snackbar(
                                  'Lỗi',
                                  'Vui lòng nhập mô tả báo cáo',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              reportQuiz(quizId, description);
                              Get.back();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: UtilsReponsive.height(12, context),
                        ),
                      ),
                      child: isSubmittingReport.value
                          ? SizedBox(
                              height: UtilsReponsive.height(20, context),
                              width: UtilsReponsive.height(20, context),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : TextConstant.subTile2(
                              context,
                              text: "Gửi báo cáo",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

