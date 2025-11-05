import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';

class QuizSetService {
  QuizSetService({required this.quizSetApi});
  QuizSetApi quizSetApi;

  Future<BaseResponse<List<QuizSetModel>>> getQuizSets() async {
    try {
      final response = await quizSetApi.getQuizSets();
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
      final response = await quizSetApi.getQuizSetsByCreator(userId);
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
}
