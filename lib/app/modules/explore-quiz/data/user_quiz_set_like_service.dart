import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_like_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/user_quiz_set_like_model.dart';

class UserQuizSetLikeService {
  UserQuizSetLikeService({required this.userQuizSetLikeApi});
  UserQuizSetLikeApi userQuizSetLikeApi;

  Future<BaseResponse<List<UserQuizSetLikeModel>>> getUserLikes(
    String userId, {
    bool includeDeleted = false,
  }) async {
    try {
      final response = await userQuizSetLikeApi.getUserLikes(
        userId,
        includeDeleted,
        {},
      );
      log("User likes response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to fetch user likes',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while fetching user likes',
      );
    }
  }

  Future<BaseResponse<bool>> toggleLike(String quizSetId, String userId) async {
    try {
      final response = await userQuizSetLikeApi.toggleLike(quizSetId, userId);
      log("Toggle like response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to toggle like',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while toggling like',
      );
    }
  }

  Future<BaseResponse<int>> getLikeCount(String quizSetId) async {
    try {
      final response = await userQuizSetLikeApi.getLikeCount(quizSetId);
      log("Get like count response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to get like count',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while getting like count',
      );
    }
  }
}

