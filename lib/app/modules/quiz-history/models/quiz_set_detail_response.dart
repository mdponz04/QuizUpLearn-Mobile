import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_quiz_set_item_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/pagination_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_model.dart';

class QuizSetDetailResponse {
  final bool success;
  final List<QuizQuizSetItemModel>? data;
  final PaginationModel? pagination;
  final dynamic message;
  final dynamic error;
  final dynamic errorType;

  QuizSetDetailResponse({
    required this.success,
    this.data,
    this.pagination,
    this.message,
    this.error,
    this.errorType,
  });

  factory QuizSetDetailResponse.fromJson(Map<String, dynamic> json) {
    // Handle both old format (data is QuizSetModel) and new format (data is List)
    List<QuizQuizSetItemModel>? dataList;
    
    if (json['data'] != null) {
      if (json['data'] is List) {
        // New format: data is a list of QuizQuizSetItemModel
        dataList = (json['data'] as List)
            .map((item) => QuizQuizSetItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (json['data'] is Map) {
        // Old format: data is a QuizSetModel - convert to new format
        // This is for backward compatibility
        final quizSetData = json['data'] as Map<String, dynamic>;
        final quizzes = quizSetData['quizzes'] as List? ?? [];
        dataList = quizzes.map((quizJson) {
          return QuizQuizSetItemModel(
            id: '',
            quizId: quizJson['id']?.toString() ?? '',
            quizSetId: quizSetData['id']?.toString() ?? '',
            createdAt: DateTime.now(),
            quiz: QuizModel.fromJson(quizJson as Map<String, dynamic>),
            quizSet: QuizSetModel.fromJson(quizSetData),
          );
        }).toList();
      }
    }
    
    return QuizSetDetailResponse(
      success: json['success'] ?? false,
      data: dataList,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      message: json['message'],
      error: json['error'],
      errorType: json['errorType'],
    );
  }

  // Helper method to extract QuizSetModel from the response
  QuizSetModel? getQuizSetModel() {
    if (data == null || data!.isEmpty) return null;
    
    // Get quizSet from first item (all items should have same quizSet)
    final quizSet = data!.first.quizSet;
    
    // Collect all quizzes from data items
    final quizzes = data!.map((item) => item.quiz).toList();
    
    // Create a new QuizSetModel with the collected quizzes
    return QuizSetModel(
      id: quizSet.id,
      title: quizSet.title,
      description: quizSet.description,
      quizType: quizSet.quizType,
      toeicPart: quizSet.toeicPart,
      skillType: quizSet.skillType,
      difficultyLevel: quizSet.difficultyLevel,
      totalQuestions: quizSet.totalQuestions,
      timeLimit: quizSet.timeLimit,
      createdBy: quizSet.createdBy,
      creatorUsername: quizSet.creatorUsername,
      isAIGenerated: quizSet.isAIGenerated,
      isPublished: quizSet.isPublished,
      isPremiumOnly: quizSet.isPremiumOnly,
      totalAttempts: quizSet.totalAttempts,
      averageScore: quizSet.averageScore,
      createdAt: quizSet.createdAt,
      updatedAt: quizSet.updatedAt,
      deletedAt: quizSet.deletedAt,
      quizzes: quizzes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((item) => item.toJson()).toList(),
      'pagination': pagination?.toJson(),
      'message': message,
      'error': error,
      'errorType': errorType,
    };
  }
}

