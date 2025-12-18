import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';

class QuizQuizSetItemModel {
  final String id;
  final String quizId;
  final String quizSetId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final QuizModel quiz;
  final QuizSetModel quizSet;

  QuizQuizSetItemModel({
    required this.id,
    required this.quizId,
    required this.quizSetId,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.quiz,
    required this.quizSet,
  });

  factory QuizQuizSetItemModel.fromJson(Map<String, dynamic> json) {
    // Extract quizSetId from parent if not in quiz
    final quizSetId = json['quizSetId']?.toString() ?? '';
    
    // Parse quiz and inject quizSetId if missing
    final quizJson = json['quiz'] as Map<String, dynamic>? ?? {};
    if (quizJson['quizSetId'] == null && quizSetId.isNotEmpty) {
      quizJson['quizSetId'] = quizSetId;
    }
    
    return QuizQuizSetItemModel(
      id: json['id']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      quizSetId: quizSetId,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'].toString())
          : null,
      quiz: QuizModel.fromJson(quizJson),
      quizSet: QuizSetModel.fromJson(json['quizSet'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'quizSetId': quizSetId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'quiz': quiz.toJson(),
      'quizSet': quizSet.toJson(),
    };
  }
}

