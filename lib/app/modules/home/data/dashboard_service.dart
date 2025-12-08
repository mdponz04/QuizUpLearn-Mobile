import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_api.dart';
import 'package:quizkahoot/app/modules/home/models/dashboard_models.dart';
import 'package:quizkahoot/app/modules/home/models/user_weak_point_model.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_response.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_all_answers_request.dart';
import 'package:quizkahoot/app/modules/single-mode/models/submit_all_answers_response.dart';

class DashboardService {
  DashboardService({required this.dashboardApi});
  DashboardApi dashboardApi;

  Future<BaseResponse<DashboardData>> getDashboard() async {
    try {
      final response = await dashboardApi.getDashboard();
      log("Dashboard response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to fetch dashboard data',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while fetching dashboard data',
      );
    }
  }

  Future<BaseResponse<List<UserWeakPointModel>>> getUserWeakPoints() async {
    try {
      final response = await dashboardApi.getUserWeakPoints();
      log("User weak points response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to fetch user weak points',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while fetching user weak points',
      );
    }
  }

  Future<BaseResponse<int>> getMistakeQuizzesCount() async {
    try {
      final response = await dashboardApi.getMistakeQuizzes(1, 100);
      log("Mistake quizzes response: ${response.toString()}");
      
      final count = response.count;
      return BaseResponse(
        isSuccess: true,
        message: 'Success',
        data: count,
      );
    } on DioException catch (e) {
      log("Error getting mistake quizzes count: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while fetching mistake quizzes',
      );
    } catch (e) {
      log("Unexpected error getting mistake quizzes count: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }

  Future<BaseResponse<StartQuizResponse>> startMistakeQuiz(StartQuizRequest request) async {
    try {
      final response = await dashboardApi.startMistakeQuiz(request);
      log("Start mistake quiz response: ${response.toString()}");
      return BaseResponse(
        isSuccess: true,
        message: 'Mistake quiz started successfully',
        data: response,
      );
    } on DioException catch (e) {
      log("Error starting mistake quiz: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while starting mistake quiz',
      );
    } catch (e) {
      log("Unexpected error starting mistake quiz: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }

  Future<BaseResponse<SubmitAllAnswersResponse>> submitMistakeQuiz(SubmitAllAnswersRequest request) async {
    try {
      final response = await dashboardApi.submitMistakeQuiz(request);
      log("Submit mistake quiz response: ${response.toString()}");
      return BaseResponse(
        isSuccess: true,
        message: 'Mistake quiz submitted successfully',
        data: response,
      );
    } on DioException catch (e) {
      log("Error submitting mistake quiz: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message']?.toString() ?? 'An error occurred while submitting mistake quiz',
      );
    } catch (e) {
      log("Unexpected error submitting mistake quiz: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }
}

