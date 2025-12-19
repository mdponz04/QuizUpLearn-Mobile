import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_favorite_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/user_quiz_set_favorite_model.dart';

class UserQuizSetFavoriteService {
  UserQuizSetFavoriteService({required this.userQuizSetFavoriteApi});
  UserQuizSetFavoriteApi userQuizSetFavoriteApi;

  Future<BaseResponse<List<UserQuizSetFavoriteModel>>> getUserFavorites(
    String userId, {
    bool includeDeleted = false,
  }) async {
    try {
      final response = await userQuizSetFavoriteApi.getUserFavorites(
        userId,
        includeDeleted,
        {},
      );
      log("User favorites response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to fetch user favorites',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while fetching user favorites',
      );
    }
  }

  Future<BaseResponse<bool>> toggleFavorite(String quizSetId, String userId) async {
    try {
      final response = await userQuizSetFavoriteApi.toggleFavorite(quizSetId, userId);
      log("Toggle favorite response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to toggle favorite',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while toggling favorite',
      );
    }
  }
}

