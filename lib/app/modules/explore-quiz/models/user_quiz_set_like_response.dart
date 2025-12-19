import 'package:quizkahoot/app/modules/explore-quiz/models/user_quiz_set_like_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/pagination_model.dart';

class UserQuizSetLikeResponse {
  final bool success;
  final List<UserQuizSetLikeModel>? data;
  final PaginationModel? pagination;
  final dynamic message;

  UserQuizSetLikeResponse({
    required this.success,
    this.data,
    this.pagination,
    this.message,
  });

  factory UserQuizSetLikeResponse.fromJson(Map<String, dynamic> json) {
    return UserQuizSetLikeResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => UserQuizSetLikeModel.fromJson(item as Map<String, dynamic>))
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

