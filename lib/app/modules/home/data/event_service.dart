import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/home/data/event_api.dart';
import 'package:quizkahoot/app/modules/home/models/event_leaderboard_model.dart';
import 'package:quizkahoot/app/modules/home/models/event_model.dart';

class EventService {
  EventService({required this.eventApi});
  EventApi eventApi;

  Future<BaseResponse<List<EventModel>>> getAllEvents() async {
    try {
      final response = await eventApi.getAllEvents();
      log("Events response: ${response.toString()}");

      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message ?? 'Failed to fetch events',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while fetching events',
      );
    }
  }

  Future<BaseResponse<EventLeaderboardData>> getEventLeaderboard(String eventId) async {
    try {
      final response = await eventApi.getEventLeaderboard(eventId);
      log("Event leaderboard response: ${response.toString()}");

      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message ?? 'Failed to fetch event leaderboard',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while fetching event leaderboard',
      );
    }
  }

  Future<BaseResponse<String>> joinEvent(String eventId) async {
    try {
      final response = await eventApi.joinEvent(eventId);
      log("Join event response: ${response.toString()}");

      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: response.message ?? 'Đăng ký tham gia thành công',
          data: response.data ?? 'Success',
        );
      } else {
        return BaseResponse.error(
          response.message ?? 'Failed to join event',
        );
      }
    } on DioException catch (e) {
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while joining event',
      );
    }
  }
}

