import 'package:quizkahoot/app/modules/explore-quiz/models/answer_option_model.dart';

class QuizModel {
  final String id;
  final String quizSetId;
  final String questionText;
  final String correctAnswer;
  final String audioURL;
  final String imageURL;
  final String toeicPart;
  final int timesAnswered;
  final int timesCorrect;
  final int orderIndex;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime deletedAt;
  final List<AnswerOptionModel> answerOptions;

  QuizModel({
    required this.id,
    required this.quizSetId,
    required this.questionText,
    required this.correctAnswer,
    required this.audioURL,
    required this.imageURL,
    required this.toeicPart,
    required this.timesAnswered,
    required this.timesCorrect,
    required this.orderIndex,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.answerOptions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'],
      quizSetId: json['quizSetId'],
      questionText: json['questionText'],
      correctAnswer: json['correctAnswer'],
      audioURL: json['audioURL'],
      imageURL: json['imageURL'],
      toeicPart: json['toeicPart'],
      timesAnswered: json['timesAnswered'],
      timesCorrect: json['timesCorrect'],
      orderIndex: json['orderIndex'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: DateTime.parse(json['deletedAt']),
      answerOptions: (json['answerOptions'] as List)
          .map((item) => AnswerOptionModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizSetId': quizSetId,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'audioURL': audioURL,
      'imageURL': imageURL,
      'toeicPart': toeicPart,
      'timesAnswered': timesAnswered,
      'timesCorrect': timesCorrect,
      'orderIndex': orderIndex,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt.toIso8601String(),
      'answerOptions': answerOptions.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods
  double get accuracyRate {
    if (timesAnswered == 0) return 0.0;
    return (timesCorrect / timesAnswered) * 100;
  }

  bool get hasAudio => audioURL.isNotEmpty;
  bool get hasImage => imageURL.isNotEmpty;
}
