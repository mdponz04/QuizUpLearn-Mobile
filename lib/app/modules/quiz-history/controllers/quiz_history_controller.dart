import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/quiz-history/data/quiz_history_api.dart';
import 'package:quizkahoot/app/modules/quiz-history/data/quiz_history_service.dart';
import 'package:quizkahoot/app/modules/quiz-history/models/quiz_attempt_history_model.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class QuizHistoryController extends GetxController {
  late QuizHistoryService quizHistoryService;
  
  var isLoading = false.obs;
  var historyList = <QuizAttemptHistoryModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    loadHistory();
  }

  void _initializeDio() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizHistoryService = QuizHistoryService(
      quizHistoryApi: QuizHistoryApi(dio, baseUrl: baseUrl),
    );
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final userId = BaseCommon.instance.userId;
      if (userId.isEmpty) {
        errorMessage.value = 'User ID not found. Please login again.';
        isLoading.value = false;
        return;
      }

      final response = await quizHistoryService.getUserHistory(userId);
      
      if (response.isSuccess && response.data != null) {
        historyList.value = response.data!;
        log('Loaded ${historyList.length} history items');
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      log("Error loading history: $e");
      errorMessage.value = 'Failed to load history. Please try again.';
      Get.snackbar(
        'Error',
        'Failed to load history. Please try again.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String getAccuracyText(double accuracy) {
    return '${(accuracy * 100).toStringAsFixed(0)}%';
  }

  String getAttemptTypeText(String attemptType) {
    switch (attemptType.toLowerCase()) {
      case 'single':
        return 'Single Mode';
      case 'multi':
        return 'Multiplayer';
      case 'room':
        return 'Room Game';
      default:
        return attemptType;
    }
  }
}

