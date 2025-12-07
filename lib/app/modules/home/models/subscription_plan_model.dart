class SubscriptionPlanModel {
  final String id;
  final String name;
  final int price;
  final int durationDays;
  final bool canAccessPremiumContent;
  final bool canAccessAiFeatures;
  final int aiGenerateQuizSetMaxTimes;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.canAccessPremiumContent,
    required this.canAccessAiFeatures,
    required this.aiGenerateQuizSetMaxTimes,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      price: json["price"] ?? 0,
      durationDays: json["durationDays"] ?? 0,
      canAccessPremiumContent: json["canAccessPremiumContent"] ?? false,
      canAccessAiFeatures: json["canAccessAiFeatures"] ?? false,
      aiGenerateQuizSetMaxTimes: json["aiGenerateQuizSetMaxTimes"] ?? 0,
      isActive: json["isActive"] ?? false,
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"],
      deletedAt: json["deletedAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "durationDays": durationDays,
      "canAccessPremiumContent": canAccessPremiumContent,
      "canAccessAiFeatures": canAccessAiFeatures,
      "aiGenerateQuizSetMaxTimes": aiGenerateQuizSetMaxTimes,
      "isActive": isActive,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "deletedAt": deletedAt,
    };
  }

  String get formattedPrice {
    if (price == 0) return "Miễn phí";
    return "${(price / 1000).toStringAsFixed(0)}k VNĐ";
  }

  String get formattedDuration {
    if (durationDays >= 999999) return "Vĩnh viễn";
    if (durationDays >= 365) {
      final years = (durationDays / 365).toStringAsFixed(0);
      return "$years ${years == '1' ? 'năm' : 'năm'}";
    }
    if (durationDays >= 30) {
      final months = (durationDays / 30).toStringAsFixed(0);
      return "$months ${months == '1' ? 'tháng' : 'tháng'}";
    }
    return "$durationDays ${durationDays == 1 ? 'ngày' : 'ngày'}";
  }
}

