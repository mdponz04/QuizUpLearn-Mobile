import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/home/data/dashboard_api.dart';
import 'package:quizkahoot/app/modules/home/models/dashboard_models.dart';
import 'package:quizkahoot/app/modules/home/models/user_weak_point_model.dart';

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
}

