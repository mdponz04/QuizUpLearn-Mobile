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
      
      // Kiểm tra nếu response có success = false
      if (response.success == false) {
        // Ưu tiên lấy message, nếu không có thì lấy error
        final errorMessage = response.message?.toString();
        final errorText = errorMessage != null && errorMessage.isNotEmpty
            ? errorMessage
            : (response.error?.toString() ?? 'Failed to start quiz');
        return BaseResponse.error(errorText);
      }
      
      return BaseResponse(
        isSuccess: true,
        message: 'Quiz started successfully',
        data: response,
      );
    } on DioException catch (e) {
      log("Error starting quiz: ${e.response?.data}");
      log("Error message from DioException: ${e.message}");
      log("Error type: ${e.type}");
      
      // Ưu tiên lấy message từ response, nếu không có thì lấy error
      final errorData = e.response?.data;
      String? errorMessage;
      
      if (errorData is Map) {
        // Lấy message
        final messageValue = errorData['message'];
        if (messageValue != null) {
          errorMessage = messageValue.toString();
          // Nếu message là "null" string hoặc rỗng, thì coi như null
          if (errorMessage == 'null' || errorMessage.isEmpty) {
            errorMessage = null;
          }
        }
        
        // Nếu không có message hoặc message rỗng, lấy error
        if (errorMessage == null || errorMessage.isEmpty) {
          final errorValue = errorData['error'];
          if (errorValue != null) {
            errorMessage = errorValue.toString();
          }
        }
        
        log("Extracted errorMessage: ${errorMessage}");
      }
      
      // Nếu vẫn không có, thử lấy từ e.message (đã được set trong interceptor)
      if ((errorMessage == null || errorMessage.isEmpty) && e.message != null) {
        errorMessage = e.message;
        log("Using errorMessage from DioException.message: ${errorMessage}");
      }
      
      return BaseResponse.error(
        errorMessage ?? 'An error occurred while starting quiz',
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
