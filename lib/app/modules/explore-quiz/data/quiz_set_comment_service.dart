import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_comment_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_comment_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/create_quiz_set_comment_request.dart';

class QuizSetCommentService {
  QuizSetCommentService({required this.quizSetCommentApi});
  QuizSetCommentApi quizSetCommentApi;

  Future<BaseResponse<List<QuizSetCommentModel>>> getQuizSetComments(
    String quizSetId, {
    bool includeDeleted = false,
  }) async {
    try {
      final response = await quizSetCommentApi.getQuizSetComments(
        quizSetId,
        includeDeleted,
        {},
      );
      log("Quiz set comments response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to fetch quiz set comments',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while fetching quiz set comments',
      );
    }
  }

  Future<BaseResponse<void>> createComment(CreateQuizSetCommentRequest request) async {
    try {
      final response = await quizSetCommentApi.createComment(request.toJson());
      log("Create comment response: ${response.toString()}");
      
      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Comment created successfully',
          data: null,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to create comment',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while creating comment',
      );
    }
  }
}

