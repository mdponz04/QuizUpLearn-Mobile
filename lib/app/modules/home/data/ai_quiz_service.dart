import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/home/data/ai_quiz_api.dart';
import 'package:quizkahoot/app/modules/home/models/generate_quiz_request.dart';
import 'package:quizkahoot/app/modules/home/models/generate_quiz_response.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class AIQuizService {
  AIQuizService({required this.aiQuizApi});
  AIQuizApi aiQuizApi;

  Future<BaseResponse<GenerateQuizResponse>> generateQuiz(
    int quizPart,
    GenerateQuizRequest request,
  ) async {
    try {
      final response = await aiQuizApi.generateQuiz(quizPart, request);
      
      log("AI Quiz generation response: ${response.toString()}");
      return BaseResponse(
        isSuccess: true,
        message: 'Quiz generated successfully',
        data: response,
      );
    } on DioException catch (e) {
      log("Error generating quiz: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'Failed to generate quiz. Please try again.',
      );
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }
}

