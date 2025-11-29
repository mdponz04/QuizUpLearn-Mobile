import 'package:quizkahoot/app/modules/tournament/models/tournament_model.dart';

class TournamentResponse {
  final bool success;
  final List<TournamentModel> data;
  final String message;
  final dynamic error;
  final dynamic errorType;

  TournamentResponse({
    required this.success,
    required this.data,
    required this.message,
    this.error,
    this.errorType,
  });

  factory TournamentResponse.fromJson(Map<String, dynamic> json) {
    return TournamentResponse(
      success: json["success"] ?? false,
      data: (json["data"] as List? ?? [])
          .map((item) => TournamentModel.fromJson(item))
          .toList(),
      message: json["message"] ?? "OK",
      error: json["error"],
      errorType: json["errorType"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data.map((item) => item.toJson()).toList(),
      "message": message,
      "error": error,
      "errorType": errorType,
    };
  }
}

