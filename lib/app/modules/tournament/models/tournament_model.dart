import 'package:flutter/material.dart';

class TournamentModel {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final String status;
  final int totalQuizSets;

  TournamentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.status,
    required this.totalQuizSets,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      startDate: DateTime.parse(json["startDate"] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json["endDate"] ?? DateTime.now().toIso8601String()),
      maxParticipants: json["maxParticipants"] ?? 0,
      status: json["status"] ?? "",
      totalQuizSets: json["totalQuizSets"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "maxParticipants": maxParticipants,
      "status": status,
      "totalQuizSets": totalQuizSets,
    };
  }

  String get formattedStartDate {
    return "${startDate.day}/${startDate.month}/${startDate.year}";
  }

  String get formattedEndDate {
    return "${endDate.day}/${endDate.month}/${endDate.year}";
  }

  String get formattedDateRange {
    return "$formattedStartDate - $formattedEndDate";
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'started':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'ended':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

