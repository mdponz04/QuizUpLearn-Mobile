class TournamentJoinedResponse {
  final bool success;
  final TournamentJoinedData data;
  final String message;
  final dynamic error;
  final dynamic errorType;

  TournamentJoinedResponse({
    required this.success,
    required this.data,
    required this.message,
    this.error,
    this.errorType,
  });

  factory TournamentJoinedResponse.fromJson(Map<String, dynamic> json) {
    return TournamentJoinedResponse(
      success: json["success"] ?? false,
      data: TournamentJoinedData.fromJson(json["data"] ?? {}),
      message: json["message"] ?? "",
      error: json["error"],
      errorType: json["errorType"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data.toJson(),
      "message": message,
      "error": error,
      "errorType": errorType,
    };
  }
}

class TournamentJoinedData {
  final bool isJoined;

  TournamentJoinedData({
    required this.isJoined,
  });

  factory TournamentJoinedData.fromJson(Map<String, dynamic> json) {
    return TournamentJoinedData(
      isJoined: json["isJoined"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isJoined": isJoined,
    };
  }
}

