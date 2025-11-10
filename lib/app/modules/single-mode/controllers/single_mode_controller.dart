import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/single-mode/data/single_mode_api.dart';
import 'package:quizkahoot/app/modules/single-mode/data/single_mode_service.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_answer_request.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class SingleModeController extends GetxController {
  late SingleModeService singleModeService;
  
  // Quiz state
  var isLoading = false.obs;
  var currentQuestionIndex = 0.obs;
  var selectedAnswer = ''.obs;
  var timeRemaining = 0.obs;
  var isQuizCompleted = false.obs;
  
  // Quiz data
  var quizData = Rxn<StartQuizResponse>();
  var currentQuestion = Rxn<Question>();
  var userAnswers = <String, String>{}.obs;
  var questionStartTimes = <String, DateTime>{}.obs;
  
  // Timer
  Timer? _timer;
  
  // User info
  String? userId;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    _getUserId();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _initializeDio() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    singleModeService = SingleModeService(singleModeApi: SingleModeApi(dio, baseUrl: baseUrl));
  }

  Future<void> _getUserId() async {
    userId = BaseCommon.instance.userId;
  }

  Future<void> startQuiz(String quizSetId) async {
    if (userId == null) {
      Get.snackbar(
        'Error',
        'User not found. Please login again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      final request = StartQuizRequest(
        quizSetId: quizSetId,
        userId: userId!,
      );
      
      final response = await singleModeService.startQuiz(request);
      
      if (response.isSuccess && response.data != null) {
        quizData.value = response.data!;
        _initializeQuiz();
        Get.toNamed('/quiz-playing');
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log(e.toString());
      Get.snackbar(
        'Error',
        'Failed to start quiz. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeQuiz() {
    if (quizData.value == null || quizData.value!.data == null) return;
    
    currentQuestionIndex.value = 0;
    selectedAnswer.value = '';
    isQuizCompleted.value = false;
    userAnswers.clear();
    questionStartTimes.clear();
    
    // Set a default time limit since it's not in the new response structure
    timeRemaining.value = 30 * 60; // 30 minutes default
    
    _loadCurrentQuestion();
    _startTimer();
  }

  void _loadCurrentQuestion() {
    if (quizData.value == null || 
        quizData.value!.data == null ||
        quizData.value!.data!.questions == null ||
        currentQuestionIndex.value >= quizData.value!.data!.questions!.length) {
      return;
    }
    
    final question = quizData.value!.data!.questions![currentQuestionIndex.value];
    currentQuestion.value = question;
    selectedAnswer.value = userAnswers[question.id ?? ''] ?? '';
    
    // Record question start time
    if (question.id != null) {
      questionStartTimes[question.id!] = DateTime.now();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining.value > 0) {
        timeRemaining.value--;
      } else {
        _finishQuiz();
      }
    });
  }

  void selectAnswer(String answer) {
    selectedAnswer.value = answer;
  }

  Future<void> submitAnswer() async {
    if (selectedAnswer.value.isEmpty || currentQuestion.value == null) {
      Get.snackbar(
        'Warning',
        'Please select an answer',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Calculate time spent on this question
      final questionId = currentQuestion.value!.id ?? '';
      final questionStartTime = questionStartTimes[questionId];
      final timeSpent = questionStartTime != null 
          ? DateTime.now().difference(questionStartTime).inSeconds
          : 0;

      final request = SubmitAnswerRequest(
        attemptId: quizData.value!.data?.attemptId ?? '',
        questionId: questionId,
        userAnswer: selectedAnswer.value,
        timeSpent: timeSpent,
      );

      final response = await singleModeService.submitAnswer(request);
      
      if (response.isSuccess && response.data != null) {
        // Store user answer
        userAnswers[questionId] = selectedAnswer.value;
        
        // Move to next question
        _nextQuestion();
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit answer. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _nextQuestion() {
    if (quizData.value?.data?.questions != null &&
        currentQuestionIndex.value < quizData.value!.data!.questions!.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswer.value = '';
      _loadCurrentQuestion();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    if (quizData.value == null) return;
    
    try {
      _timer?.cancel();
      
      final response = await singleModeService.finishQuiz(quizData.value!.data?.attemptId ?? '');
      
      if (response.isSuccess && response.data != null) {
        isQuizCompleted.value = true;
        Get.toNamed('/quiz-result', arguments: response.data!);
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to finish quiz. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void skipQuestion() {
    if (currentQuestion.value != null && currentQuestion.value!.id != null) {
      userAnswers[currentQuestion.value!.id!] = '';
      _nextQuestion();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      _loadCurrentQuestion();
    }
  }

  // Helper getters
  int get totalQuestions => quizData.value?.data?.questions?.length ?? 0;
  int get currentQuestionNumber => currentQuestionIndex.value + 1;
  double get progress => totalQuestions > 0 ? (currentQuestionIndex.value + 1) / totalQuestions : 0.0;
  
  String get formattedTimeRemaining {
    final minutes = timeRemaining.value ~/ 60;
    final seconds = timeRemaining.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  bool get isLastQuestion => currentQuestionIndex.value >= totalQuestions - 1;
  bool get isFirstQuestion => currentQuestionIndex.value == 0;
}
