import 'package:quizkahoot/app/modules/home/models/subscription_plan_model.dart';

class SubscriptionPlanResponse {
  final bool success;
  final List<SubscriptionPlanModel> data;
  final dynamic message;

  SubscriptionPlanResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SubscriptionPlanResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResponse(
      success: json["success"] ?? false,
      data: (json["data"] as List? ?? [])
          .map((item) => SubscriptionPlanModel.fromJson(item))
          .toList(),
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data.map((item) => item.toJson()).toList(),
      "message": message,
    };
  }
}

