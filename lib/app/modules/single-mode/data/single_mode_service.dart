import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/single-mode/data/single_mode_api.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_all_answers_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_all_answers_response.dart';

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

  Future<BaseResponse<SubmitAllAnswersResponse>> submitAllAnswers(SubmitAllAnswersRequest request) async {
    try {
      final response = await singleModeApi.submitAllAnswers(request);
      log("Submit all answers response: ${response.toString()}");
      return BaseResponse(
        isSuccess: true,
        message: 'Answers submitted successfully',
        data: response,
      );
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while submitting answers',
      );
    }
  }

  Future<BaseResponse<SubmitAllAnswersResponse>> submitPlacementTest(SubmitAllAnswersRequest request) async {
    try {
      final response = await singleModeApi.submitPlacementTest(request);
      log("Submit placement test response: ${response.toString()}");
      return BaseResponse(
        isSuccess: true,
        message: 'Placement test submitted successfully',
        data: response,
      );
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while submitting placement test',
      );
    }
  }
}
