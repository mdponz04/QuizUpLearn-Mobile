import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/quiz_event_model.dart';
import '../data/quiz_event_data.dart';

class PlayEventController extends GetxController {
  // Event data
  final allEvents = <QuizEventModel>[].obs;
  final selectedType = QuizEventType.solo.obs;
  final selectedStatus = QuizEventStatus.upcoming.obs;
  final searchQuery = ''.obs;

  // Statistics
  final totalEvents = 0.obs;
  final upcomingEvents = 0.obs;
  final ongoingEvents = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void loadEvents() {
    allEvents.value = QuizEventData.getAllEvents();
    updateStatistics();
  }

  void updateStatistics() {
    totalEvents.value = allEvents.length;
    upcomingEvents.value = QuizEventData.getUpcomingEvents().length;
    ongoingEvents.value = QuizEventData.getOngoingEvents().length;
  }

  void setSelectedType(QuizEventType type) {
    selectedType.value = type;
  }

  void setSelectedStatus(QuizEventStatus status) {
    selectedStatus.value = status;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }


  List<QuizEventModel> get filteredEvents {
    List<QuizEventModel> events = allEvents;

    // Filter by type
    if (selectedType.value != QuizEventType.solo) {
      events = events.where((event) => event.type == selectedType.value).toList();
    }

    // Filter by status
    if (selectedStatus.value != QuizEventStatus.upcoming) {
      events = events.where((event) => event.status == selectedStatus.value).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      events = events.where((event) =>
          event.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          event.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          event.topics.any((topic) => topic.toLowerCase().contains(searchQuery.value.toLowerCase()))).toList();
    }


    // Sort: ongoing first, then upcoming, then by start time
    events.sort((a, b) {
      if (a.status != b.status) {
        if (a.isOngoing) return -1;
        if (b.isOngoing) return 1;
        if (a.isUpcoming) return -1;
        if (b.isUpcoming) return 1;
      }
      return a.startTime.compareTo(b.startTime);
    });

    return events;
  }

  List<QuizEventModel> getEventsByType(QuizEventType type) {
    return allEvents.where((event) => event.type == type).toList();
  }

  List<QuizEventModel> getEventsByStatus(QuizEventStatus status) {
    return allEvents.where((event) => event.status == status).toList();
  }

  List<QuizEventType> get allTypes => QuizEventType.values;
  List<QuizEventStatus> get allStatuses => QuizEventStatus.values;


  void startEvent(String eventId) {
    final event = allEvents.firstWhere((e) => e.id == eventId);
    
    if (event.type == QuizEventType.solo) {
      // TODO: Navigate to solo quiz screen
      Get.snackbar(
        "Starting Quiz",
        "Quiz ${event.title} is starting...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } else if (event.type == QuizEventType.multiplayerSolo) {
      // Navigate to matching screen for multiplayer solo
      Get.toNamed('/find-matching', arguments: {
        'eventId': eventId,
        'eventType': event.type.name,
        'eventTitle': event.title,
      });
    } else if (event.type == QuizEventType.oneOnOne || event.type == QuizEventType.group) {
      // Navigate to matching screen
      Get.toNamed('/find-matching', arguments: {
        'eventId': eventId,
        'eventType': event.type.name,
        'eventTitle': event.title,
      });
    }
  }
}
