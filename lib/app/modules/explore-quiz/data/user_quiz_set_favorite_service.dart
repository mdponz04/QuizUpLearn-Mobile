import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/user_quiz_set_favorite_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/user_quiz_set_favorite_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/create_user_quiz_set_favorite_request.dart';

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

  Future<BaseResponse<void>> createFavorite(CreateUserQuizSetFavoriteRequest request) async {
    try {
      final response = await userQuizSetFavoriteApi.createFavorite(request.toJson());
      log("Create favorite response: ${response.toString()}");
      
      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Favorite added successfully',
          data: null,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to add favorite',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while adding favorite',
      );
    }
  }
}

