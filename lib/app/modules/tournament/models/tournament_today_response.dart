class TournamentTodayResponse {
  final bool success;
  final TournamentTodayData? data;
  final String? message;
  final dynamic error;
  final dynamic errorType;

  TournamentTodayResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  factory TournamentTodayResponse.fromJson(Map<String, dynamic> json) {
    return TournamentTodayResponse(
      success: json["success"] ?? false,
      data: json["data"] != null ? TournamentTodayData.fromJson(json["data"]) : null,
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

class TournamentTodayData {
  final String tournamentId;
  final DateTime startDate;
  final DateTime endDate;
  final String quizSetId;
  final int dayNumber;

  TournamentTodayData({
    required this.tournamentId,
    required this.startDate,
    required this.endDate,
    required this.quizSetId,
    required this.dayNumber,
  });

  factory TournamentTodayData.fromJson(Map<String, dynamic> json) {
    return TournamentTodayData(
      tournamentId: json["tournamentId"] ?? "",
      startDate: DateTime.parse(json["startDate"] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json["endDate"] ?? DateTime.now().toIso8601String()),
      quizSetId: json["quizSetId"] ?? "",
      dayNumber: json["dayNumber"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tournamentId": tournamentId,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "quizSetId": quizSetId,
      "dayNumber": dayNumber,
    };
  }
}

