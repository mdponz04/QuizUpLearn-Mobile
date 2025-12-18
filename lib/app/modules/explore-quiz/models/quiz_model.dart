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
  final DateTime? updatedAt;
  final DateTime? deletedAt;
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
    this.updatedAt,
    this.deletedAt,
    required this.answerOptions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id']?.toString() ?? '',
      quizSetId: json['quizSetId']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? '',
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      audioURL: json['audioURL']?.toString() ?? '',
      imageURL: json['imageURL']?.toString() ?? '',
      toeicPart: json['toeicPart']?.toString() ?? '',
      timesAnswered: json['timesAnswered'] ?? 0,
      timesCorrect: json['timesCorrect'] ?? 0,
      orderIndex: json['orderIndex'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'].toString())
          : null,
      answerOptions: (json['answerOptions'] as List?)
          ?.map((item) => AnswerOptionModel.fromJson(item))
          .toList() ?? [],
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
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
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
