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
    int partNumber,
    GenerateQuizRequest request,
  ) async {
    try {
      GenerateQuizResponse response;
      
      switch (partNumber) {
        case 1:
          response = await aiQuizApi.generateQuizPart1(request);
          break;
        case 2:
          response = await aiQuizApi.generateQuizPart2(request);
          break;
        case 3:
          response = await aiQuizApi.generateQuizPart3(request);
          break;
        case 4:
          response = await aiQuizApi.generateQuizPart4(request);
          break;
        case 5:
          response = await aiQuizApi.generateQuizPart5(request);
          break;
        case 6:
          response = await aiQuizApi.generateQuizPart6(request);
          break;
        case 7:
          response = await aiQuizApi.generateQuizPart7(request);
          break;
        default:
          return BaseResponse.error('Invalid part number');
      }
      
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

