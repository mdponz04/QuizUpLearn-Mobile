import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_api.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_service.dart';
import 'package:quizkahoot/app/modules/home/models/dashboard_models.dart';
import 'package:quizkahoot/app/modules/home/models/user_weak_point_model.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class DashboardDetailController extends GetxController {
  late DashboardService dashboardService;
  
  // Observable variables
  var isLoading = false.obs;
  var isLoadingWeakPoints = false.obs;
  var dashboardData = Rxn<DashboardData>();
  var weakPoints = <UserWeakPointModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDashboardService();
    loadDashboardData();
    loadWeakPoints();
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
}

