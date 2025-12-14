import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/update_quiz_set_request.dart';

class QuizSetService {
  QuizSetService({required this.quizSetApi});
  QuizSetApi quizSetApi;

  Future<BaseResponse<List<QuizSetModel>>> getQuizSets() async {
    try {
      final response = await quizSetApi.getQuizSets({});
      log("Quiz sets response: ${response.toString()}");
      
      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message ?? 'Failed to fetch quiz sets',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while fetching quiz sets',
      );
    }
  }

  Future<BaseResponse<List<QuizSetModel>>> getQuizSetsByCreator(String userId) async {
    try {
      final response = await quizSetApi.getQuizSetsByCreator(userId, {});
      log("Quiz sets by creator response: ${response.toString()}");
      
      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message ?? 'Failed to fetch quiz sets',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while fetching quiz sets',
      );
    }
  }

  Future<BaseResponse<List<QuizSetModel>>> searchQuizSets(Map<String, dynamic> body) async {
    try {
      final response = await quizSetApi.searchQuizSets(body);
      log("Search quiz sets response: ${response.toString()}");
      
      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message ?? 'Failed to search quiz sets',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while searching quiz sets',
      );
    }
  }

  Future<BaseResponse<QuizSetModel>> getQuizSetDetail(String quizSetId, {bool includeDeleted = false}) async {
    try {
      final response = await quizSetApi.getQuizSetById(quizSetId, includeDeleted, {});
      log("Quiz set detail response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to fetch quiz set detail',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while fetching quiz set detail',
      );
    }
  }

  Future<BaseResponse<QuizSetModel>> updateQuizSet(
    String quizSetId,
    UpdateQuizSetRequest request,
  ) async {
    try {
      final response = await quizSetApi.updateQuizSet(quizSetId, request.toJson());
      log("Update quiz set response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to update quiz set',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while updating quiz set',
      );
    }
  }
}
