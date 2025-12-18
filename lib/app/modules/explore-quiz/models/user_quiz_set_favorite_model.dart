import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_comment_user_model.dart';

class UserQuizSetFavoriteModel {
  final String id;
  final String userId;
  final String quizSetId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final QuizSetCommentUserModel user;
  final QuizSetModel quizSet;

  UserQuizSetFavoriteModel({
    required this.id,
    required this.userId,
    required this.quizSetId,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.user,
    required this.quizSet,
  });

  factory UserQuizSetFavoriteModel.fromJson(Map<String, dynamic> json) {
    return UserQuizSetFavoriteModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      quizSetId: json['quizSetId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'].toString())
          : null,
      user: QuizSetCommentUserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      quizSet: QuizSetModel.fromJson(json['quizSet'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'quizSetId': quizSetId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'user': user.toJson(),
      'quizSet': quizSet.toJson(),
    };
  }
}

