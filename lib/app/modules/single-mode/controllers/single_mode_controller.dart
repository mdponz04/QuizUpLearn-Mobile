import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_api.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_service.dart';
import 'package:quizkahoot/app/modules/single-mode/data/single_mode_api.dart';
import 'package:quizkahoot/app/modules/single-mode/data/single_mode_service.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_all_answers_request.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class SingleModeController extends GetxController {
  late SingleModeService singleModeService;
  DashboardService? dashboardService;
  
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
  
  // Quiz Group Audio (for entire quiz set)
  var quizGroupAudioUrl = ''.obs;
  
  // Timer
  Timer? _timer;
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  var isAudioPlaying = false.obs;
  var isAudioLoading = false.obs;
  var hasAudioPlayed = false.obs; // Track if audio has been played for current question (for placement test)
  
  // User info
  String? userId;
  
  // Flag to identify if this is a placement test
  var isPlacementTest = false.obs;
  
  // Flag to identify if this is a mistake quiz (khắc phục)
  var isMistakeQuiz = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    _getUserId();
    _setupAudioPlayer();
  }
  
  void _setupAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      isAudioPlaying.value = state == PlayerState.playing;
      if (state == PlayerState.playing || state == PlayerState.completed) {
        isAudioLoading.value = false;
      }
    });
    
    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      isAudioPlaying.value = false;
      // Mark audio as played when it completes (for placement test)
      if (isPlacementTest.value) {
        hasAudioPlayed.value = true;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }

  void _initializeDio() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    singleModeService = SingleModeService(singleModeApi: SingleModeApi(dio, baseUrl: baseUrl));
    
    // Initialize dashboard service for mistake quiz
    final dashboardDio = Dio();
    dashboardDio.interceptors.add(DioIntercepTorCustom());
    dashboardService = DashboardService(dashboardApi: DashboardApi(dashboardDio, baseUrl: baseUrl));
  }

  Future<void> _getUserId() async {
    userId = BaseCommon.instance.userId;
  }

  Future<void> startQuiz(String quizSetId, {bool isPlacement = false}) async {
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
      isPlacementTest.value = isPlacement;
      
      final request = StartQuizRequest(
        quizSetId: quizSetId,
        userId: userId!,
      );
      
      final response = await singleModeService.startQuiz(request);
      
      if (response.isSuccess && response.data != null) {
        quizData.value = response.data!;
        
        // Load quiz group audio if available
        await _loadQuizGroupAudio();
        
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

  Future<void> _loadQuizGroupAudio() async {
    try {
      // Get first question's quizGroupItemId
      final questions = quizData.value?.data?.questions;
      if (questions == null || questions.isEmpty) {
        return;
      }
      
      final firstQuizGroupItemId = questions.first.quizGroupItemId;
      if (firstQuizGroupItemId == null || firstQuizGroupItemId.isEmpty) {
        log('No quizGroupItemId found in first question');
        return;
      }
      
      log('Loading quiz group item: $firstQuizGroupItemId');
      
      // Call API to get quiz group item
      final response = await singleModeService.getQuizGroupItem(firstQuizGroupItemId);
      
      if (response.isSuccess && response.data != null && response.data!.data != null) {
        final audioUrl = response.data!.data!.audioUrl;
        if (audioUrl.isNotEmpty) {
          quizGroupAudioUrl.value = audioUrl;
          log('Quiz group audio URL loaded: $audioUrl');
        }
      } else {
        log('Failed to load quiz group item: ${response.message}');
      }
    } catch (e) {
      log('Error loading quiz group audio: $e');
    }
  }
  
  void _initializeQuiz() {
    initializeQuiz();
  }
  
  void initializeQuiz() {
    if (quizData.value == null || quizData.value!.data == null) return;
    
    currentQuestionIndex.value = 0;
    selectedAnswer.value = '';
    isQuizCompleted.value = false;
    userAnswers.clear();
    questionStartTimes.clear();
    quizGroupAudioUrl.value = ''; // Reset group audio URL
    
    // Set a default time limit since it's not in the new response structure
    timeRemaining.value = 30 * 60; // 30 minutes default
    
    _loadCurrentQuestion();
    _startTimer();
  }
  
  // Reset placement test flag when needed
  void resetPlacementTestFlag() {
    isPlacementTest.value = false;
  }
  
  // Reset mistake quiz flag when needed
  void resetMistakeQuizFlag() {
    isMistakeQuiz.value = false;
  }

  void _loadCurrentQuestion() {
    if (quizData.value == null || 
        quizData.value!.data == null ||
        quizData.value!.data!.questions == null ||
        currentQuestionIndex.value >= quizData.value!.data!.questions!.length) {
      return;
    }
    
    // Only stop audio if not using quiz group audio (whole quiz audio)
    // If using quiz group audio, let it play continuously
    if (quizGroupAudioUrl.value.isEmpty) {
      stopAudio();
    }
    
    final question = quizData.value!.data!.questions![currentQuestionIndex.value];
    currentQuestion.value = question;
    selectedAnswer.value = userAnswers[question.id ?? ''] ?? '';
    
    // Reset audio played flag for new question (for placement test)
    // Only reset if not using quiz group audio
    if (quizGroupAudioUrl.value.isEmpty) {
      hasAudioPlayed.value = false;
    }
    
    // Record question start time
    if (question.id != null) {
      questionStartTimes[question.id!] = DateTime.now();
    }
  }
  
  Future<void> playAudio() async {
    // Priority: Use quiz group audio if available, otherwise use question audio
    String? audioUrl = quizGroupAudioUrl.value.isNotEmpty 
        ? quizGroupAudioUrl.value 
        : currentQuestion.value?.audioUrl;
    
    if (audioUrl == null || audioUrl.isEmpty) {
      Get.snackbar(
        'Info',
        'No audio available for this question',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }
    
    // For placement test: check if audio has already been played
    if (isPlacementTest.value && hasAudioPlayed.value) {
      Get.snackbar(
        'Thông báo',
        'Bạn chỉ được phát audio một lần cho câu hỏi này',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isAudioLoading.value = true;
      await _audioPlayer.play(UrlSource(audioUrl));
      // Don't mark as played here - wait until audio completes
    } catch (e) {
      log('Error playing audio: $e');
      isAudioLoading.value = false;
      isAudioPlaying.value = false;
      Get.snackbar(
        'Error',
        'Failed to play audio. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      isAudioPlaying.value = false;
    } catch (e) {
      log('Error pausing audio: $e');
    }
  }
  
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      isAudioPlaying.value = false;
      isAudioLoading.value = false;
    } catch (e) {
      log('Error stopping audio: $e');
    }
  }
  
  Future<void> toggleAudio() async {
    // For placement test: if audio has already completed playing, don't allow toggle
    if (isPlacementTest.value && hasAudioPlayed.value && !isAudioPlaying.value) {
      Get.snackbar(
        'Thông báo',
        'Bạn chỉ được phát audio một lần cho câu hỏi này',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    if (isAudioPlaying.value) {
      await pauseAudio();
    } else {
      await playAudio();
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
    // Save answer locally when selected
    if (currentQuestion.value?.id != null) {
      userAnswers[currentQuestion.value!.id!] = answer;
    }
  }

  void saveCurrentAnswer() {
    // Save current answer before moving to next question
    if (currentQuestion.value?.id != null && selectedAnswer.value.isNotEmpty) {
      userAnswers[currentQuestion.value!.id!] = selectedAnswer.value;
    }
  }

  void _nextQuestion() {
    // Save current answer before moving
    saveCurrentAnswer();
    
    if (quizData.value?.data?.questions != null &&
        currentQuestionIndex.value < quizData.value!.data!.questions!.length - 1) {
      currentQuestionIndex.value++;
      _loadCurrentQuestion();
    } else {
      _finishQuiz();
    }
  }

  void nextQuestion() {
    _nextQuestion();
  }

  void finishQuiz() {
    _finishQuiz();
  }

  Future<void> _finishQuiz() async {
    if (quizData.value == null) return;
    
    try {
      _timer?.cancel();
      isLoading.value = true;
      
      // Save current answer if any
      saveCurrentAnswer();
      
      // Calculate time spent for all questions
      final attemptId = quizData.value!.data?.attemptId ?? '';
      final questions = quizData.value!.data?.questions ?? [];
      
      final answers = <AnswerDetail>[];
      
      for (var question in questions) {
        final questionId = question.id ?? '';
        final userAnswer = userAnswers[questionId] ?? '';
        final startTime = questionStartTimes[questionId];
        
        // Calculate time spent (if startTime exists, use it; otherwise 0)
        int timeSpent = 0;
        if (startTime != null) {
          timeSpent = DateTime.now().difference(startTime).inSeconds;
        }
        
        answers.add(AnswerDetail(
          questionId: questionId,
          userAnswer: userAnswer,
          timeSpent: timeSpent,
        ));
      }
      
      final request = SubmitAllAnswersRequest(
        attemptId: attemptId,
        answers: answers,
      );
      
      // Use different endpoint based on quiz type
      dynamic response;
      if (isMistakeQuiz.value && dashboardService != null) {
        // Use mistake quiz submit endpoint
        response = await dashboardService!.submitMistakeQuiz(request);
      } else if (isPlacementTest.value) {
        // Use placement test submit endpoint
        response = await singleModeService.submitPlacementTest(request);
      } else {
        // Use normal submit endpoint
        response = await singleModeService.submitAllAnswers(request);
      }
      
      if (response.isSuccess && response.data != null && response.data!.data != null) {
        isQuizCompleted.value = true;
        // Pass the response data to result screen
        Get.toNamed('/quiz-result', arguments: response.data!.data!);
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
        'Failed to finish quiz. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void skipQuestion() {
    // Save empty answer for skipped question
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
