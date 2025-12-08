import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_api.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_service.dart';
import 'package:quizkahoot/app/modules/home/models/dashboard_models.dart';
import 'package:quizkahoot/app/modules/home/models/user_weak_point_model.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';
import 'package:quizkahoot/app/modules/single-mode/models/start_quiz_request.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class DashboardDetailController extends GetxController {
  late DashboardService dashboardService;
  
  // Observable variables
  var isLoading = false.obs;
  var isLoadingWeakPoints = false.obs;
  var dashboardData = Rxn<DashboardData>();
  var weakPoints = <UserWeakPointModel>[].obs;
  var mistakeQuizzesCount = 0.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDashboardService();
    loadDashboardData();
    loadWeakPoints();
    loadMistakeQuizzes();
  }

  void _initializeDashboardService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    dashboardService = DashboardService(
      dashboardApi: DashboardApi(dio, baseUrl: baseUrl),
    );
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await dashboardService.getDashboard();
      if (response.isSuccess && response.data != null) {
        dashboardData.value = response.data;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      log('Error loading dashboard: $e');
      errorMessage.value = 'Failed to load dashboard data. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWeakPoints() async {
    try {
      isLoadingWeakPoints.value = true;
      
      final response = await dashboardService.getUserWeakPoints();
      if (response.isSuccess && response.data != null) {
        weakPoints.value = response.data!;
      }
    } catch (e) {
      log('Error loading weak points: $e');
    } finally {
      isLoadingWeakPoints.value = false;
    }
  }

  Future<void> loadMistakeQuizzes() async {
    try {
      final response = await dashboardService.getMistakeQuizzesCount();
      if (response.isSuccess && response.data != null) {
        mistakeQuizzesCount.value = response.data!;
      }
    } catch (e) {
      log('Error loading mistake quizzes count: $e');
    }
  }

  Future<void> startMistakeQuiz() async {
    final userId = BaseCommon.instance.userId;
    if (userId.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // API mistake-quizzes không cần quizSetId, có thể truyền empty string
      final request = StartQuizRequest(
        quizSetId: '', // API sẽ tự động lấy từ user mistakes
        userId: userId,
      );
      
      final response = await dashboardService.startMistakeQuiz(request);
      
      if (response.isSuccess && response.data != null) {
        // Initialize SingleModeController và set quiz data
        Get.lazyPut<SingleModeController>(() => SingleModeController());
        final singleModeController = Get.find<SingleModeController>();
        
        // Set quiz data và flag isMistakeQuiz
        singleModeController.quizData.value = response.data!;
        singleModeController.isMistakeQuiz.value = true;
        singleModeController.initializeQuiz();
        
        // Navigate to quiz playing screen
        Get.toNamed('/quiz-playing');
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('Error starting mistake quiz: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể bắt đầu làm bài khắc phục. Vui lòng thử lại.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

