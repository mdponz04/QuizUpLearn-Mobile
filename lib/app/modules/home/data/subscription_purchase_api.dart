import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/purchase_subscription_request.dart';
import 'package:quizkahoot/app/modules/home/models/purchase_subscription_response.dart';
import 'package:retrofit/retrofit.dart';

part 'subscription_purchase_api.g.dart';

@RestApi()
abstract class SubscriptionPurchaseApi {
  factory SubscriptionPurchaseApi(Dio dio, {required String? baseUrl}) = _SubscriptionPurchaseApi;
  
  @POST('/buysubscription/purchase')
  Future<PurchaseSubscriptionResponse> purchaseSubscription(
    @Body() PurchaseSubscriptionRequest request,
  );
}

