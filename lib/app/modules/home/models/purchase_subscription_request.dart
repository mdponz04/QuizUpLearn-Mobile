class PurchaseSubscriptionRequest {
  final String userId;
  final String planId;
  final String successUrl;
  final String cancelUrl;

  PurchaseSubscriptionRequest({
    required this.userId,
    required this.planId,
    required this.successUrl,
    required this.cancelUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'planId': planId,
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
    };
  }
}

