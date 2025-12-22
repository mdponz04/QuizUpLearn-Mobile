import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/explore-quiz/data/quiz_report_api.dart';

class QuizReportService {
  QuizReportService({required this.quizReportApi});
  QuizReportApi quizReportApi;

  Future<BaseResponse<void>> reportQuiz({
    required String userId,
    required String quizId,
    required String description,
  }) async {
    try {
      final body = {
        'userId': userId,
        'quizId': quizId,
        'description': description,
      };
      
      final response = await quizReportApi.reportQuiz(body);
      log("Quiz report response: ${response.toString()}");
      
      return BaseResponse(
        isSuccess: true,
        message: 'Report submitted successfully',
        data: null,
      );
    } on DioException catch (e) {
      log("Error reporting quiz: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'Failed to submit report. Please try again.',
      );
    } catch (e) {
      log("Unexpected error reporting quiz: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }
}

