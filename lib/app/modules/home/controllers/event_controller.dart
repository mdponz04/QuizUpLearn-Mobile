import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/home/data/event_api.dart';
import 'package:quizkahoot/app/modules/home/data/event_service.dart';
import 'package:quizkahoot/app/modules/home/models/event_model.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class EventController extends GetxController {
  late EventService eventService;
  
  // Observable variables
  var isLoading = false.obs;
  var events = <EventModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeEventService();
    loadEvents();
  }

  void _initializeEventService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    eventService = EventService(eventApi: EventApi(dio, baseUrl: baseUrl));
  }

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await eventService.getAllEvents();
      if (response.isSuccess && response.data != null) {
        events.value = response.data!;
        // Sort events: Upcoming first, then Ongoing, then Ended
        events.sort((a, b) {
          if (a.isUpcoming && !b.isUpcoming) return -1;
          if (!a.isUpcoming && b.isUpcoming) return 1;
          if (a.isOngoing && !b.isOngoing) return -1;
          if (!a.isOngoing && b.isOngoing) return 1;
          // For same status, sort by start date (newest first)
          return b.startDate.compareTo(a.startDate);
        });
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      log('Error loading events: $e');
      errorMessage.value = 'Không thể tải danh sách sự kiện. Vui lòng thử lại.';
    } finally {
      isLoading.value = false;
    }
  }

  void refreshEvents() {
    loadEvents();
  }
}

