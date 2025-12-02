import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_plan_api.dart';
import 'package:quizkahoot/app/modules/home/models/subscription_plan_model.dart';
import 'package:quizkahoot/app/modules/home/models/user_subscription_model.dart';

class SubscriptionPlanService {
  SubscriptionPlanService({required this.subscriptionPlanApi});
  SubscriptionPlanApi subscriptionPlanApi;

  Future<BaseResponse<List<SubscriptionPlanModel>>> getSubscriptionPlans() async {
    try {
      final response = await subscriptionPlanApi.getSubscriptionPlans();
      log("Subscription plans response: ${response.toString()}");
      
      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to fetch subscription plans',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while fetching subscription plans',
      );
    }
  }

  Future<BaseResponse<UserSubscriptionModel>> getUserSubscription() async {
    try {
      final response = await subscriptionPlanApi.getUserSubscription();
      log("User subscription response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'No active subscription found',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while fetching user subscription',
      );
    }
  }
}

