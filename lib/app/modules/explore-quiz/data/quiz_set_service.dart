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
        // Ưu tiên lấy message, nếu không có thì lấy error
        final errorMessage = response.message?.toString();
        final errorText = errorMessage != null && errorMessage.isNotEmpty
            ? errorMessage
            : (response.error?.toString() ?? 'Failed to search quiz sets');
        return BaseResponse.error(errorText);
      }
    } on DioException catch (e) {
      // Ưu tiên lấy message từ response, nếu không có thì lấy error
      final errorData = e.response?.data;
      String? errorMessage;
      if (errorData is Map) {
        errorMessage = errorData['message']?.toString();
        if (errorMessage == null || errorMessage.isEmpty) {
          errorMessage = errorData['error']?.toString();
        }
      }
      return BaseResponse.error(
        errorMessage ?? 'An error occurred while searching quiz sets',
      );
    }
  }

  Future<BaseResponse<QuizSetModel>> getQuizSetDetail(String quizSetId, {bool includeDeleted = false}) async {
    try {
      final response = await quizSetApi.getQuizSetById(quizSetId, includeDeleted, {});
      log("Quiz set detail response: ${response.toString()}");
      
      if (response.success) {
        // Extract QuizSetModel from the new response format
        final quizSetModel = response.getQuizSetModel();
        
        if (quizSetModel != null) {
          return BaseResponse(
            isSuccess: true,
            message: 'Success',
            data: quizSetModel,
          );
        } else {
          return BaseResponse.error(
            'No quiz set data found in response',
          );
        }
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
          data: response.getQuizSetModel(),
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
