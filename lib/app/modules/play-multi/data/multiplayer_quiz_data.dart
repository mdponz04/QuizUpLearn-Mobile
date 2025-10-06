import '../models/multiplayer_quiz_model.dart';
import '../../play-solo/data/quiz_questions_data.dart';
import '../../find_matching/models/matching_model.dart';

class MultiplayerQuizData {
  static List<QuizQuestionModel> getQuestions() {
    final questions = QuizQuestionsData.getQuestions();
    return questions.map((q) => QuizQuestionModel(
      id: q.id,
      question: q.question,
      options: q.options,
      correctAnswerIndex: q.correctAnswerIndex,
      explanation: q.explanation,
      difficulty: q.difficulty,
      topic: q.topic,
      timeLimit: q.timeLimit,
    )).toList();
  }

  static List<QuizQuestionModel> getRandomQuestions(int count) {
    final questions = QuizQuestionsData.getRandomQuestions(count);
    return questions.map((q) => QuizQuestionModel(
      id: q.id,
      question: q.question,
      options: q.options,
      correctAnswerIndex: q.correctAnswerIndex,
      explanation: q.explanation,
      difficulty: q.difficulty,
      topic: q.topic,
      timeLimit: q.timeLimit,
    )).toList();
  }

  static List<PlayerScore> generateLeaderboard(List<MatchingModel> participants) {
    final now = DateTime.now();
    final leaderboard = <PlayerScore>[];
    
    // Sort participants by rating (higher rating = better performance simulation)
    final sortedParticipants = List<MatchingModel>.from(participants);
    sortedParticipants.sort((a, b) => b.rating.compareTo(a.rating));
    
    for (int i = 0; i < sortedParticipants.length; i++) {
      final participant = sortedParticipants[i];
      final rank = i + 1;
      
      // Simulate performance based on rating
      final rating = participant.rating;
      final baseAccuracy = (rating - 1000) / 1000.0; // 0.0 to 1.0
      final accuracy = (baseAccuracy * 0.4 + 0.3).clamp(0.2, 0.9); // 20% to 90%
      
      final totalQuestions = 20;
      final correctAnswers = (totalQuestions * accuracy).round();
      final score = correctAnswers * 10; // 10 points per correct answer
      
      // Generate random answers
      final answers = List.generate(totalQuestions, (index) {
        return index < correctAnswers;
      });
      answers.shuffle();
      
      leaderboard.add(PlayerScore(
        playerId: participant.id,
        playerName: participant.name,
        playerAvatar: participant.avatar,
        score: score,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        accuracy: accuracy,
        totalTime: (totalQuestions * 15) + (now.millisecond % 300), // Random time
        answers: answers,
        currentRank: rank,
        previousRank: rank, // Same for initial
      ));
    }
    
    return leaderboard;
  }

  static List<PlayerScore> updateLeaderboard(List<PlayerScore> currentLeaderboard, String playerId, bool isCorrect) {
    // Find current player
    final playerIndex = currentLeaderboard.indexWhere((p) => p.playerId == playerId);
    if (playerIndex == -1) return currentLeaderboard;
    
    final currentPlayer = currentLeaderboard[playerIndex];
    
    // Update player score
    final newScore = currentPlayer.score + (isCorrect ? 10 : 0);
    final newCorrectAnswers = currentPlayer.correctAnswers + (isCorrect ? 1 : 0);
    final newAnswers = List<bool>.from(currentPlayer.answers)..add(isCorrect);
    final newAccuracy = newCorrectAnswers / newAnswers.length;
    
    // Create updated player
    final updatedPlayer = PlayerScore(
      playerId: currentPlayer.playerId,
      playerName: currentPlayer.playerName,
      playerAvatar: currentPlayer.playerAvatar,
      score: newScore,
      correctAnswers: newCorrectAnswers,
      totalQuestions: currentPlayer.totalQuestions,
      accuracy: newAccuracy,
      totalTime: currentPlayer.totalTime,
      answers: newAnswers,
      currentRank: currentPlayer.currentRank,
      previousRank: currentPlayer.currentRank,
    );
    
    // Update leaderboard
    final updatedLeaderboard = List<PlayerScore>.from(currentLeaderboard);
    updatedLeaderboard[playerIndex] = updatedPlayer;
    
    // Sort by score (descending)
    updatedLeaderboard.sort((a, b) => b.score.compareTo(a.score));
    
    // Update ranks
    for (int i = 0; i < updatedLeaderboard.length; i++) {
      final player = updatedLeaderboard[i];
      updatedLeaderboard[i] = PlayerScore(
        playerId: player.playerId,
        playerName: player.playerName,
        playerAvatar: player.playerAvatar,
        score: player.score,
        correctAnswers: player.correctAnswers,
        totalQuestions: player.totalQuestions,
        accuracy: player.accuracy,
        totalTime: player.totalTime,
        answers: player.answers,
        currentRank: i + 1,
        previousRank: player.currentRank,
      );
    }
    
    return updatedLeaderboard;
  }

  static List<PlayerScore> getTopPlayers(List<PlayerScore> leaderboard, int count) {
    return leaderboard.take(count).toList();
  }

  static PlayerScore? getCurrentPlayerScore(List<PlayerScore> leaderboard, String playerId) {
    try {
      return leaderboard.firstWhere((p) => p.playerId == playerId);
    } catch (e) {
      return null;
    }
  }

  static List<PlayerScore> getPlayersAroundCurrent(List<PlayerScore> leaderboard, String playerId, int range) {
    final currentIndex = leaderboard.indexWhere((p) => p.playerId == playerId);
    if (currentIndex == -1) return [];
    
    final start = (currentIndex - range).clamp(0, leaderboard.length - 1);
    final end = (currentIndex + range + 1).clamp(0, leaderboard.length);
    
    return leaderboard.sublist(start, end);
  }

  static Map<String, dynamic> getQuizStats(List<PlayerScore> leaderboard) {
    if (leaderboard.isEmpty) {
      return {
        'totalPlayers': 0,
        'averageScore': 0.0,
        'highestScore': 0,
        'lowestScore': 0,
        'averageAccuracy': 0.0,
      };
    }
    
    final totalPlayers = leaderboard.length;
    final totalScore = leaderboard.fold(0, (sum, player) => sum + player.score);
    final averageScore = totalScore / totalPlayers;
    final highestScore = leaderboard.first.score;
    final lowestScore = leaderboard.last.score;
    final totalAccuracy = leaderboard.fold(0.0, (sum, player) => sum + player.accuracy);
    final averageAccuracy = totalAccuracy / totalPlayers;
    
    return {
      'totalPlayers': totalPlayers,
      'averageScore': averageScore,
      'highestScore': highestScore,
      'lowestScore': lowestScore,
      'averageAccuracy': averageAccuracy,
    };
  }
}
