import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/home/data/subscription_purchase_api.dart';
import 'package:quizkahoot/app/modules/home/models/purchase_subscription_request.dart';
import 'package:quizkahoot/app/modules/home/models/purchase_subscription_response.dart';

class SubscriptionPurchaseService {
  SubscriptionPurchaseService({required this.subscriptionPurchaseApi});
  SubscriptionPurchaseApi subscriptionPurchaseApi;

  Future<BaseResponse<PurchaseSubscriptionData>> purchaseSubscription({
    required String userId,
    required String planId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final request = PurchaseSubscriptionRequest(
        userId: userId,
        planId: planId,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );
      
      final response = await subscriptionPurchaseApi.purchaseSubscription(request);
      log("Purchase subscription response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message ?? 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message ?? response.error?.toString() ?? 'Failed to create payment link',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while creating payment link',
      );
    }
  }
}

