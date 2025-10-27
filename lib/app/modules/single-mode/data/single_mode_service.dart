import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/single-mode/data/single_mode_api.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_answer_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_answer_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/finish_quiz_response.dart';

class SingleModeService {
  SingleModeService({required this.singleModeApi});
  SingleModeApi singleModeApi;

  Future<BaseResponse<StartQuizResponse>> startQuiz(StartQuizRequest request) async {
    try {
      final response = await singleModeApi.startQuiz(request);
      log("Start quiz response: ${response.toString()}");
      return BaseResponse(
        isSuccess: true,
        message: 'Quiz started successfully',
        data: response,
      );
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while starting quiz',
      );
    }
  }

  Future<BaseResponse<SubmitAnswerResponse>> submitAnswer(SubmitAnswerRequest request) async {
    try {
      final response = await singleModeApi.submitAnswer(request);
      log("Submit answer response: ${response.toString()}");
      return BaseResponse(
        isSuccess: true,
        message: 'Answer submitted successfully',
        data: response,
      );
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while submitting answer',
      );
    }
  }

  Future<BaseResponse<FinishQuizResponse>> finishQuiz(String attemptId) async {
    try {
      final response = await singleModeApi.finishQuiz(attemptId);
      log("Finish quiz response: ${response.toString()}");
      return BaseResponse(
        isSuccess: true,
        message: 'Quiz completed successfully',
        data: response,
      );
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while finishing quiz',
      );
    }
  }
}
