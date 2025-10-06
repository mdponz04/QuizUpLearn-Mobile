import '../../find_matching/models/matching_model.dart';

class MultiplayerQuizModel {
  final String id;
  final String sessionId;
  final String eventId;
  final String eventTitle;
  final List<MatchingModel> participants;
  final List<QuizQuestionModel> questions;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalQuestions;
  final int timePerQuestion; // in seconds
  final String difficulty;
  final MultiplayerQuizStatus status;

  MultiplayerQuizModel({
    required this.id,
    required this.sessionId,
    required this.eventId,
    required this.eventTitle,
    required this.participants,
    required this.questions,
    required this.startTime,
    this.endTime,
    required this.totalQuestions,
    required this.timePerQuestion,
    required this.difficulty,
    required this.status,
  });

  factory MultiplayerQuizModel.fromJson(Map<String, dynamic> json) {
    return MultiplayerQuizModel(
      id: json['id'],
      sessionId: json['sessionId'],
      eventId: json['eventId'],
      eventTitle: json['eventTitle'],
      participants: (json['participants'] as List)
          .map((p) => MatchingModel.fromJson(p))
          .toList(),
      questions: (json['questions'] as List)
          .map((q) => QuizQuestionModel.fromJson(q))
          .toList(),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      totalQuestions: json['totalQuestions'],
      timePerQuestion: json['timePerQuestion'],
      difficulty: json['difficulty'],
      status: MultiplayerQuizStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'participants': participants.map((p) => p.toJson()).toList(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalQuestions': totalQuestions,
      'timePerQuestion': timePerQuestion,
      'difficulty': difficulty,
      'status': status.name,
    };
  }
}

class QuizQuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String difficulty;
  final String topic;
  final int timeLimit; // in seconds

  QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
    required this.topic,
    required this.timeLimit,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      explanation: json['explanation'],
      difficulty: json['difficulty'],
      topic: json['topic'],
      timeLimit: json['timeLimit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'difficulty': difficulty,
      'topic': topic,
      'timeLimit': timeLimit,
    };
  }
}

class PlayerScore {
  final String playerId;
  final String playerName;
  final String playerAvatar;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int totalTime; // in seconds
  final List<bool> answers; // true for correct, false for incorrect
  final int currentRank;
  final int previousRank;

  PlayerScore({
    required this.playerId,
    required this.playerName,
    required this.playerAvatar,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    required this.totalTime,
    required this.answers,
    required this.currentRank,
    required this.previousRank,
  });

  factory PlayerScore.fromJson(Map<String, dynamic> json) {
    return PlayerScore(
      playerId: json['playerId'],
      playerName: json['playerName'],
      playerAvatar: json['playerAvatar'],
      score: json['score'],
      correctAnswers: json['correctAnswers'],
      totalQuestions: json['totalQuestions'],
      accuracy: json['accuracy'].toDouble(),
      totalTime: json['totalTime'],
      answers: List<bool>.from(json['answers']),
      currentRank: json['currentRank'],
      previousRank: json['previousRank'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'playerAvatar': playerAvatar,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'totalTime': totalTime,
      'answers': answers,
      'currentRank': currentRank,
      'previousRank': previousRank,
    };
  }
}

enum MultiplayerQuizStatus {
  waiting,
  inProgress,
  completed,
}

enum QuestionStatus {
  waiting,
  answered,
  timeUp,
}

enum LeaderboardUpdateType {
  realTime,
  questionEnd,
  quizEnd,
}
