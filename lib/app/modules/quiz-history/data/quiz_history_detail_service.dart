import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/models/quiz_set_model.dart';
import 'package:quizkahoot/app/modules/quiz-history/data/quiz_history_detail_api.dart';
import 'package:quizkahoot/app/modules/quiz-history/models/quiz_attempt_detail_model.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_set_api.dart';

class QuizHistoryDetailService {
  QuizHistoryDetailService({
    required this.quizHistoryDetailApi,
    required this.quizSetApi,
  });
  
  final QuizHistoryDetailApi quizHistoryDetailApi;
  final QuizSetApi quizSetApi;

  Future<BaseResponse<List<QuizAttemptDetailModel>>> getAttemptDetails(
    String attemptId,
  ) async {
    try {
      final response = await quizHistoryDetailApi.getAttemptDetails(
        attemptId,
        false, // isDeleted
      );
      log("Get attempt details response: ${response.toString()}");

      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Attempt details loaded successfully',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to load attempt details',
        );
      }
    } on DioException catch (e) {
      log("Error getting attempt details: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while loading attempt details',
      );
    } catch (e) {
      log("Error getting attempt details: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }

  Future<BaseResponse<QuizSetModel>> getQuizSetById(String quizSetId) async {
    try {
      final response = await quizSetApi.getQuizSetById(quizSetId, false, {});
      log("Get quiz set by id response: ${response.toString()}");

      if (response.success) {
        // Extract QuizSetModel from the new response format
        final quizSetModel = response.getQuizSetModel();
        
        if (quizSetModel != null) {
          return BaseResponse(
            isSuccess: true,
            message: response.message?.toString() ?? 'Quiz set loaded successfully',
            data: quizSetModel,
          );
        } else {
          return BaseResponse.error(
            'No quiz set data found in response',
          );
        }
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to load quiz set',
        );
      }
    } on DioException catch (e) {
      log("Error getting quiz set: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while loading quiz set',
      );
    } catch (e) {
      log("Error getting quiz set: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }
}

