class PurchaseSubscriptionResponse {
  final bool success;
  final PurchaseSubscriptionData? data;
  final String? message;
  final dynamic error;
  final dynamic errorType;

  PurchaseSubscriptionResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory PurchaseSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseSubscriptionResponse(
      success: json["success"] ?? false,
      data: json["data"] != null
          ? PurchaseSubscriptionData.fromJson(json["data"])
          : null,
      message: json["message"],
      error: json["error"],
      errorType: json["errorType"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data?.toJson(),
      "message": message,
      "error": error,
      "errorType": errorType,
    };
  }
}

class PurchaseSubscriptionData {
  final int orderCode;
  final String qrCodeUrl;

  PurchaseSubscriptionData({
    required this.orderCode,
    required this.qrCodeUrl,
  });

  factory PurchaseSubscriptionData.fromJson(Map<String, dynamic> json) {
    return PurchaseSubscriptionData(
      orderCode: json["orderCode"] ?? 0,
      qrCodeUrl: json["qrCodeUrl"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderCode": orderCode,
      "qrCodeUrl": qrCodeUrl,
    };
  }
}

