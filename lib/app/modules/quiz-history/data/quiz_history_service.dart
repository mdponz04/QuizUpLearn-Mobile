import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/quiz-history/data/quiz_history_api.dart';
import 'package:quizkahoot/app/modules/quiz-history/models/quiz_attempt_history_model.dart';

class QuizHistoryService {
  QuizHistoryService({required this.quizHistoryApi});
  QuizHistoryApi quizHistoryApi;

  Future<BaseResponse<List<QuizAttemptHistoryModel>>> getUserHistory(String userId) async {
    try {
      final response = await quizHistoryApi.getUserHistory(userId);
      log("Get user history response: ${response.toString()}");

      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'History loaded successfully',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to load history',
        );
      }
    } on DioException catch (e) {
      log("Error getting user history: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while loading history',
      );
    } catch (e) {
      log("Error getting user history: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }

  Future<BaseResponse<List<QuizAttemptHistoryModel>>> getUserHistoryWithFilters(
    String userId, {
    String? quizSetId,
    String? status,
    String? attemptType,
  }) async {
    try {
      final response = await quizHistoryApi.getUserHistory(
        userId,
        quizSetId: quizSetId,
        status: status,
        attemptType: attemptType,
      );
      log("Get user history with filters response: ${response.toString()}");

      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'History loaded successfully',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to load history',
        );
      }
    } on DioException catch (e) {
      log("Error getting user history with filters: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while loading history',
      );
    } catch (e) {
      log("Error getting user history with filters: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }
}

