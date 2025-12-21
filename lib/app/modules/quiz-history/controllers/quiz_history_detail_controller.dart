import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/answer_option_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/quiz-history/data/quiz_history_detail_api.dart';
import 'package:quizkahoot/app/modules/quiz-history/data/quiz_history_detail_service.dart';
import 'package:quizkahoot/app/modules/quiz-history/models/quiz_attempt_detail_model.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class QuizHistoryDetailController extends GetxController {
  late QuizHistoryDetailService quizHistoryDetailService;
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  
  // Data
  var quizSet = Rxn<QuizSetModel>();
  var attemptDetails = <QuizAttemptDetailModel>[].obs;
  var attemptType = ''.obs; // Store attemptType
  
  // Combined data for display
  var quizWithAnswers = <QuizWithAnswer>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    
    // Get parameters from route
    final attemptId = Get.parameters['attemptId'];
    final quizSetId = Get.parameters['quizSetId'];
    final attemptTypeParam = Get.parameters['attemptType'];
    
    if (attemptId != null && quizSetId != null) {
      attemptType.value = attemptTypeParam ?? '';
      loadDetail(attemptId, quizSetId);
    } else {
      errorMessage.value = 'Thiếu tham số bắt buộc';
    }
  }

  void _initializeDio() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    quizHistoryDetailService = QuizHistoryDetailService(
      quizHistoryDetailApi: QuizHistoryDetailApi(dio, baseUrl: baseUrl),
      quizSetApi: QuizSetApi(dio, baseUrl: baseUrl),
    );
  }

  Future<void> loadDetail(String attemptId, String quizSetId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Load both APIs in parallel
      final results = await Future.wait([
        quizHistoryDetailService.getAttemptDetails(attemptId),
        quizHistoryDetailService.getQuizSetById(quizSetId),
      ]);
      
      final attemptDetailsResponse = results[0] as BaseResponse<List<QuizAttemptDetailModel>>;
      final quizSetResponse = results[1] as BaseResponse<QuizSetModel>;
      
      if (!attemptDetailsResponse.isSuccess || attemptDetailsResponse.data == null) {
        errorMessage.value = attemptDetailsResponse.message;
        isLoading.value = false;
        return;
      }
      
      if (!quizSetResponse.isSuccess || quizSetResponse.data == null) {
        errorMessage.value = quizSetResponse.message;
        isLoading.value = false;
        return;
      }
      
      // Store data
      quizSet.value = quizSetResponse.data;
      attemptDetails.value = attemptDetailsResponse.data!;
      
      // Map quizzes with user answers
      _mapQuizzesWithAnswers();
      
      log('Loaded ${attemptDetails.length} attempt details and ${quizSet.value?.quizzes.length ?? 0} quizzes');
    } catch (e) {
      log("Error loading detail: $e");
      errorMessage.value = 'Không thể tải chi tiết. Vui lòng thử lại.';
      Get.snackbar(
        'Lỗi',
        'Không thể tải chi tiết. Vui lòng thử lại.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _mapQuizzesWithAnswers() {
    if (quizSet.value == null) return;
    
    final quizzes = quizSet.value!.quizzes;
    final detailsMap = <String, QuizAttemptDetailModel>{};
    
    // Create a map of questionId -> attempt detail
    for (var detail in attemptDetails) {
      detailsMap[detail.questionId] = detail;
    }
    
    // Combine quizzes with their attempt details
    quizWithAnswers.value = quizzes.map((quiz) {
      final detail = detailsMap[quiz.id];
      return QuizWithAnswer(
        quiz: quiz,
        attemptDetail: detail,
      );
    }).toList();
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }
}

// Helper class to combine quiz with attempt detail
class QuizWithAnswer {
  final QuizModel quiz;
  final QuizAttemptDetailModel? attemptDetail;

  QuizWithAnswer({
    required this.quiz,
    this.attemptDetail,
  });

  bool get hasAnswer => attemptDetail != null;
  
  // Logic đúng: So sánh userAnswer với option có isCorrect = true
  bool get isCorrect {
    if (attemptDetail == null || attemptDetail!.userAnswer.isEmpty) {
      return false;
    }
    
    // Tìm option có isCorrect = true trong answerOptions
    try {
      final correctOption = quiz.answerOptions.firstWhere(
        (option) => option.isCorrect == true,
      );
      
      // So sánh userAnswer với id của option đúng
      return attemptDetail!.userAnswer == correctOption.id;
    } catch (e) {
      // Nếu không tìm thấy option nào có isCorrect = true, trả về false
      log("Warning: No correct option found for quiz ${quiz.id}");
      return false;
    }
  }
  
  String? get userAnswerId => attemptDetail?.userAnswer;
  int get timeSpent => attemptDetail?.timeSpent ?? 0;
  
  // Helper để lấy option đúng
  AnswerOptionModel? get correctOption {
    try {
      return quiz.answerOptions.firstWhere(
        (option) => option.isCorrect == true,
      );
    } catch (e) {
      return null;
    }
  }
}

