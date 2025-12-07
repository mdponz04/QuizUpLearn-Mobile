import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/home/data/event_api.dart';
import 'package:quizkahoot/app/modules/home/data/event_service.dart';
import 'package:quizkahoot/app/modules/home/models/event_leaderboard_model.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class EventDetailController extends GetxController {
  late EventService eventService;
  
  // Observable variables
  var isLoading = false.obs;
  var isJoining = false.obs;
  var isCheckingJoined = false.obs;
  var isJoined = false.obs;
  var leaderboardData = Rxn<EventLeaderboardData>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeEventService();
    
    // Get event ID from arguments
    final eventId = Get.arguments as String?;
    if (eventId != null) {
      checkEventJoinedStatus(eventId);
      loadEventLeaderboard(eventId);
    }
  }

  void _initializeEventService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    eventService = EventService(eventApi: EventApi(dio, baseUrl: baseUrl));
  }

  Future<void> loadEventLeaderboard(String eventId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await eventService.getEventLeaderboard(eventId);
      if (response.isSuccess && response.data != null) {
        leaderboardData.value = response.data;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      log('Error loading event leaderboard: $e');
      errorMessage.value = 'Không thể tải bảng xếp hạng. Vui lòng thử lại.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshLeaderboard() async {
    final eventId = Get.arguments as String?;
    if (eventId != null) {
      await loadEventLeaderboard(eventId);
    }
  }

  Future<void> checkEventJoinedStatus(String eventId) async {
    try {
      isCheckingJoined.value = true;
      
      final response = await eventService.getEventJoinedStatus(eventId);
      if (response.isSuccess && response.data != null) {
        isJoined.value = response.data!;
      } else {
        // Default to false if check fails
        isJoined.value = false;
      }
    } catch (e) {
      log('Error checking joined status: $e');
      // Default to false on error
      isJoined.value = false;
    } finally {
      isCheckingJoined.value = false;
    }
  }

  Future<bool> joinEvent() async {
    try {
      final eventId = Get.arguments as String?;
      if (eventId == null) {
        return false;
      }

      isJoining.value = true;
      
      final response = await eventService.joinEvent(eventId);
      if (response.isSuccess) {
        // Update joined status
        isJoined.value = true;
        // Refresh leaderboard after joining
        await loadEventLeaderboard(eventId);
        return true;
      } else {
        errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      log('Error joining event: $e');
      errorMessage.value = 'Không thể đăng ký tham gia. Vui lòng thử lại.';
      return false;
    } finally {
      isJoining.value = false;
    }
  }
}

