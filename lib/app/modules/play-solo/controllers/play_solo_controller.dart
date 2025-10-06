import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/quiz_question_model.dart';
import '../data/quiz_questions_data.dart';
import '../../find_matching/models/matching_model.dart';

class PlaySoloController extends GetxController {
  // Quiz data
  late String sessionId;
  late String eventId;
  late String eventTitle;
  late MatchingModel opponent;
  late MatchingModel currentPlayer;
  
  // Quiz state
  final questions = <QuizQuestionModel>[].obs;
  final currentQuestionIndex = 0.obs;
  final selectedAnswerIndex = Rxn<int>();
  final isAnswered = false.obs;
  final timeRemaining = 30.obs;
  final quizStatus = QuizStatus.waiting.obs;
  final questionStatus = QuestionStatus.waiting.obs;
  
  // Scores
  final currentPlayerScore = 0.obs;
  final opponentScore = 0.obs;
  final currentPlayerAnswers = <bool>[].obs;
  final opponentAnswers = <bool>[].obs;
  
  // Timer
  Timer? _questionTimer;
  Timer? _quizTimer;
  
  // UI state
  final showResult = false.obs;
  final showOpponentAnswer = false.obs;
  final opponentSelectedAnswer = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
    _loadQuestions();
  }

  @override
  void onReady() {
    super.onReady();
    _startQuiz();
  }

  @override
  void onClose() {
    _questionTimer?.cancel();
    _quizTimer?.cancel();
    super.onClose();
  }

  void _initializeFromArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      sessionId = arguments['sessionId'] ?? '';
      eventId = arguments['eventId'] ?? '';
      eventTitle = arguments['eventTitle'] ?? '1v1 Battle';
      opponent = arguments['opponent'] as MatchingModel;
      
      // Get current player (simulate from matching data)
      currentPlayer = MatchingModel(
        id: 'current_player',
        name: 'You',
        avatar: 'assets/images/astrorocket.png',
        level: 15,
        rating: 1850,
        country: 'Vietnam',
        isOnline: true,
        languages: ['English', 'Vietnamese'],
        totalMatches: 100,
        wins: 70,
        losses: 30,
        winRate: 0.70,
        preferredDifficulty: 'Intermediate',
        interests: ['Grammar', 'Vocabulary'],
      );
    }
  }

  void _loadQuestions() {
    // Load 20 random questions for the quiz
    questions.value = QuizQuestionsData.getRandomQuestions(20);
  }

  void _startQuiz() {
    quizStatus.value = QuizStatus.inProgress;
    questionStatus.value = QuestionStatus.waiting;
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    if (currentQuestionIndex.value < questions.length) {
      final currentQuestion = questions[currentQuestionIndex.value];
      timeRemaining.value = currentQuestion.timeLimit;
      
      _questionTimer?.cancel();
      _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timeRemaining.value > 0) {
          timeRemaining.value--;
        } else {
          _onTimeUp();
        }
      });
    }
  }

  void selectAnswer(int answerIndex) {
    if (!isAnswered.value) {
      selectedAnswerIndex.value = answerIndex;
      isAnswered.value = true;
      questionStatus.value = QuestionStatus.answered;
      _questionTimer?.cancel();
      
      // Simulate opponent's answer after a delay
      _simulateOpponentAnswer();
      
      // Show result after a delay
      Timer(const Duration(seconds: 2), () {
        _showQuestionResult();
      });
    }
  }

  void _simulateOpponentAnswer() {
    // Simulate opponent answering (random for demo)
    Timer(const Duration(milliseconds: 1500), () {
      final currentQuestion = questions[currentQuestionIndex.value];
      final isCorrect = (0.7 + (opponent.rating - 1500) / 1000).clamp(0.3, 0.9);
      final randomAnswer = isCorrect > 0.7 
          ? currentQuestion.correctAnswerIndex 
          : (currentQuestion.correctAnswerIndex + 1) % currentQuestion.options.length;
      
      opponentSelectedAnswer.value = randomAnswer;
      showOpponentAnswer.value = true;
    });
  }

  void _showQuestionResult() {
    showResult.value = true;
    
    // Update scores
    final currentQuestion = questions[currentQuestionIndex.value];
    final isCurrentPlayerCorrect = selectedAnswerIndex.value == currentQuestion.correctAnswerIndex;
    final isOpponentCorrect = opponentSelectedAnswer.value == currentQuestion.correctAnswerIndex;
    
    currentPlayerAnswers.add(isCurrentPlayerCorrect);
    opponentAnswers.add(isOpponentCorrect);
    
    if (isCurrentPlayerCorrect) {
      currentPlayerScore.value += 10;
    }
    if (isOpponentCorrect) {
      opponentScore.value += 10;
    }
    
    // Move to next question after delay
    Timer(const Duration(seconds: 3), () {
      _nextQuestion();
    });
  }

  void _onTimeUp() {
    if (!isAnswered.value) {
      questionStatus.value = QuestionStatus.timeUp;
      selectedAnswerIndex.value = null;
      isAnswered.value = true;
      
      // Simulate opponent's answer
      _simulateOpponentAnswer();
      
      // Show result
      Timer(const Duration(seconds: 2), () {
        _showQuestionResult();
      });
    }
  }

  void _nextQuestion() {
    showResult.value = false;
    showOpponentAnswer.value = false;
    selectedAnswerIndex.value = null;
    opponentSelectedAnswer.value = null;
    isAnswered.value = false;
    questionStatus.value = QuestionStatus.waiting;
    
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      _startQuestionTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    quizStatus.value = QuizStatus.completed;
    _questionTimer?.cancel();
    
    // Show final results
    Get.snackbar(
      "Quiz Completed!",
      "Final Score: You ${currentPlayerScore.value} - ${opponentScore.value} ${opponent.name}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: currentPlayerScore.value > opponentScore.value 
          ? Colors.green 
          : currentPlayerScore.value < opponentScore.value 
              ? Colors.red 
              : Colors.orange,
      colorText: Colors.white,
    );
  }

  // Getters
  QuizQuestionModel? get currentQuestion {
    if (currentQuestionIndex.value < questions.length) {
      return questions[currentQuestionIndex.value];
    }
    return null;
  }

  bool get isLastQuestion => currentQuestionIndex.value >= questions.length - 1;
  
  String get progressText => "${currentQuestionIndex.value + 1}/${questions.length}";
  
  double get progress => (currentQuestionIndex.value + 1) / questions.length;
  
  String get winnerText {
    if (currentPlayerScore.value > opponentScore.value) {
      return "You Win!";
    } else if (currentPlayerScore.value < opponentScore.value) {
      return "${opponent.name} Wins!";
    } else {
      return "It's a Tie!";
    }
  }
}
