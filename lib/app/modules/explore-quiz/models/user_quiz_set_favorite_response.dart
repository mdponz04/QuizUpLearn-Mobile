import 'package:quizkahoot/app/modules/explore-quiz/models/user_quiz_set_favorite_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/pagination_model.dart';

class UserQuizSetFavoriteResponse {
  final bool success;
  final List<UserQuizSetFavoriteModel>? data;
  final PaginationModel? pagination;
  final dynamic message;

  UserQuizSetFavoriteResponse({
    required this.success,
    this.data,
    this.pagination,
    this.message,
  });

  factory UserQuizSetFavoriteResponse.fromJson(Map<String, dynamic> json) {
    return UserQuizSetFavoriteResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => UserQuizSetFavoriteModel.fromJson(item as Map<String, dynamic>))
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

