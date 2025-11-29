class TournamentJoinResponse {
  final bool success;
  final dynamic data;
  final String message;
  final dynamic error;
  final dynamic errorType;

  TournamentJoinResponse({
    required this.success,
    this.data,
    required this.message,
    this.error,
    this.errorType,
  });

  factory TournamentJoinResponse.fromJson(Map<String, dynamic> json) {
    return TournamentJoinResponse(
      success: json["success"] ?? false,
      data: json["data"],
      message: json["message"] ?? "",
      error: json["error"],
      errorType: json["errorType"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data,
      "message": message,
      "error": error,
      "errorType": errorType,
    };
  }
}

