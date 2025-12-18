import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_favorite_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_favorite_service.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/user_quiz_set_favorite_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class FavoriteQuizController extends GetxController {
  late UserQuizSetFavoriteService favoriteService;
  
  // Observable variables
  var isLoading = false.obs;
  var favorites = <UserQuizSetFavoriteModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    loadFavorites();
  }

  void _initializeService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    favoriteService = UserQuizSetFavoriteService(
      userQuizSetFavoriteApi: UserQuizSetFavoriteApi(dio, baseUrl: baseUrl),
    );
  }

  Future<void> loadFavorites() async {
    try {
      final userId = BaseCommon.instance.userId;
      if (userId.isEmpty) {
        errorMessage.value = 'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.';
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await favoriteService.getUserFavorites(userId);
      
      if (response.isSuccess && response.data != null) {
        favorites.value = response.data!;
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      log("Error loading favorites: $e");
      errorMessage.value = 'Failed to load favorites. Please try again.';
      Get.snackbar(
        'Lỗi',
        'Failed to load favorites. Please try again.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get quiz sets from favorites
  List<QuizSetModel> get favoriteQuizSets {
    return favorites.map((favorite) => favorite.quizSet).toList();
  }

  Future<void> refreshFavorites() async {
    await loadFavorites();
  }
}

