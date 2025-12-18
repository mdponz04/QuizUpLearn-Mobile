import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_comment_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/pagination_model.dart';

class QuizSetCommentResponse {
  final bool success;
  final List<QuizSetCommentModel>? data;
  final PaginationModel? pagination;
  final dynamic message;

  QuizSetCommentResponse({
    required this.success,
    this.data,
    this.pagination,
    this.message,
  });

  factory QuizSetCommentResponse.fromJson(Map<String, dynamic> json) {
    return QuizSetCommentResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => QuizSetCommentModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((item) => item.toJson()).toList(),
      'pagination': pagination?.toJson(),
      'message': message,
    };
  }
}

