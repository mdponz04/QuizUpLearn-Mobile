import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/subscription_plan_response.dart';
import 'package:quizkahoot/app/modules/home/models/user_subscription_model.dart';
import 'package:retrofit/retrofit.dart';

part 'subscription_plan_api.g.dart';

@RestApi()
abstract class SubscriptionPlanApi {
  factory SubscriptionPlanApi(Dio dio, {required String? baseUrl}) = _SubscriptionPlanApi;
  
  @GET('/subscriptionplan')
  Future<SubscriptionPlanResponse> getSubscriptionPlans();

  @GET('/subscription/userId')
  Future<UserSubscriptionResponse> getUserSubscription();
}

