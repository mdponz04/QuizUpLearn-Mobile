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
    };
  }
}

enum QuizStatus {
  waiting,
  inProgress,
  completed,
}

enum QuestionStatus {
  waiting,
  answered,
  timeUp,
}
