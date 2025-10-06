import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/multiplayer_quiz_model.dart';
import '../data/multiplayer_quiz_data.dart';
import '../../find_matching/models/matching_model.dart';

class PlayMultiController extends GetxController {
  // Quiz data
  late String sessionId;
  late String eventId;
  late String eventTitle;
  late List<MatchingModel> participants;
  late MatchingModel currentPlayer;
  
  // Quiz state
  final questions = <QuizQuestionModel>[].obs;
  final currentQuestionIndex = 0.obs;
  final selectedAnswerIndex = Rxn<int>();
  final isAnswered = false.obs;
  final timeRemaining = 30.obs;
  final quizStatus = MultiplayerQuizStatus.waiting.obs;
  final questionStatus = QuestionStatus.waiting.obs;
  
  // Leaderboard
  final leaderboard = <PlayerScore>[].obs;
  final topPlayers = <PlayerScore>[].obs;
  final currentPlayerScore = Rxn<PlayerScore>();
  final currentPlayerRank = 0.obs;
  
  // Timer
  Timer? _questionTimer;
  Timer? _quizTimer;
  
  // UI state
  final showResult = false.obs;
  final showLeaderboard = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
    _loadQuestions();
    _initializeLeaderboard();
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
      eventTitle = arguments['eventTitle'] ?? 'Multiplayer Solo';
      participants = List<MatchingModel>.from(arguments['participants'] ?? []);
      
      // Get current player (first participant is current player)
      currentPlayer = participants.isNotEmpty ? participants.first : MatchingModel(
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
    questions.value = MultiplayerQuizData.getRandomQuestions(20);
  }

  void _initializeLeaderboard() {
    // Generate initial leaderboard with simulated scores
    leaderboard.value = MultiplayerQuizData.generateLeaderboard(participants);
    _updateTopPlayers();
    _updateCurrentPlayerScore();
  }

  void _startQuiz() {
    quizStatus.value = MultiplayerQuizStatus.inProgress;
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
      
      // Update leaderboard
      _updateLeaderboard(answerIndex);
      
      // Show result after a delay
      Timer(const Duration(seconds: 2), () {
        _showQuestionResult();
      });
    }
  }

  void _updateLeaderboard(int answerIndex) {
    final currentQuestion = questions[currentQuestionIndex.value];
    final isCorrect = answerIndex == currentQuestion.correctAnswerIndex;
    
    // Update leaderboard with current player's answer
    leaderboard.value = MultiplayerQuizData.updateLeaderboard(
      leaderboard,
      currentPlayer.id,
      isCorrect,
    );
    
    _updateTopPlayers();
    _updateCurrentPlayerScore();
  }

  void _updateTopPlayers() {
    topPlayers.value = MultiplayerQuizData.getTopPlayers(leaderboard, 3);
  }

  void _updateCurrentPlayerScore() {
    final score = MultiplayerQuizData.getCurrentPlayerScore(leaderboard, currentPlayer.id);
    currentPlayerScore.value = score;
    if (score != null) {
      currentPlayerRank.value = score.currentRank;
    }
  }

  void _showQuestionResult() {
    showResult.value = true;
    
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
      
      // Update leaderboard with incorrect answer
      _updateLeaderboard(-1); // -1 means no answer (incorrect)
      
      // Show result
      Timer(const Duration(seconds: 2), () {
        _showQuestionResult();
      });
    }
  }

  void _nextQuestion() {
    showResult.value = false;
    selectedAnswerIndex.value = null;
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
    quizStatus.value = MultiplayerQuizStatus.completed;
    _questionTimer?.cancel();
    
    // Show final results
    Get.snackbar(
      "Quiz Completed!",
      "You finished in ${currentPlayerRank.value}${_getOrdinalSuffix(currentPlayerRank.value)} place!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: currentPlayerRank.value <= 3 
          ? Colors.green 
          : currentPlayerRank.value <= 10 
              ? Colors.orange 
              : Colors.grey,
      colorText: Colors.white,
    );
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
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
  
  String get rankText {
    if (currentPlayerRank.value == 1) return "🥇 1st";
    if (currentPlayerRank.value == 2) return "🥈 2nd";
    if (currentPlayerRank.value == 3) return "🥉 3rd";
    return "${currentPlayerRank.value}${_getOrdinalSuffix(currentPlayerRank.value)}";
  }

  Color get rankColor {
    if (currentPlayerRank.value == 1) return Colors.amber;
    if (currentPlayerRank.value == 2) return Colors.grey[400]!;
    if (currentPlayerRank.value == 3) return Colors.orange[700]!;
    if (currentPlayerRank.value <= 10) return Colors.blue;
    return Colors.grey[600]!;
  }
}
