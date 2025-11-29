import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/tournament/data/tournament_api.dart';
import 'package:quizkahoot/app/modules/tournament/data/tournament_service.dart';
import 'package:quizkahoot/app/modules/tournament/models/tournament_model.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';
import 'package:quizkahoot/app/modules/quiz-history/data/quiz_history_api.dart';
import 'package:quizkahoot/app/modules/quiz-history/data/quiz_history_service.dart';
import 'package:quizkahoot/app/service/basecommon.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class TournamentController extends GetxController {
  late TournamentService tournamentService;
  late QuizHistoryService quizHistoryService;
  var tournaments = <TournamentModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  
  // Map to track joined status for each tournament
  var joinedStatus = <String, bool>{}.obs;
  var checkingJoined = <String, bool>{}.obs;
  
  // Map to track completed today status for each tournament
  var completedToday = <String, bool>{}.obs;
  var checkingCompletedToday = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTournamentService();
    loadTournaments();
  }

  void _initializeTournamentService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    tournamentService = TournamentService(
      tournamentApi: TournamentApi(dio, baseUrl: baseUrl),
    );
    quizHistoryService = QuizHistoryService(
      quizHistoryApi: QuizHistoryApi(dio, baseUrl: baseUrl),
    );
  }

  Future<void> loadTournaments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await tournamentService.getTournaments();
      
      if (response.isSuccess && response.data != null) {
        tournaments.value = response.data!;
        
        // Check joined status for tournaments with status "started"
        for (var tournament in response.data!) {
          final status = tournament.status.toLowerCase();
          if (status == 'started') {
            checkJoinedStatus(tournament.id);
          }
        }
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      log('Error loading tournaments: $e');
      errorMessage.value = 'Đã xảy ra lỗi khi tải danh sách tournament';
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi tải danh sách tournament',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkJoinedStatus(String tournamentId) async {
    try {
      checkingJoined[tournamentId] = true;
      
      final response = await tournamentService.checkJoined(tournamentId);
      
      if (response.isSuccess && response.data != null) {
        joinedStatus[tournamentId] = response.data!;
        
        // If joined, check if completed today
        if (response.data == true) {
          await checkCompletedTodayForJoinedTournament(tournamentId);
        }
      }
    } catch (e) {
      log('Error checking joined status for tournament $tournamentId: $e');
    } finally {
      checkingJoined[tournamentId] = false;
    }
  }

  bool isJoined(String tournamentId) {
    return joinedStatus[tournamentId] ?? false;
  }

  bool isLoadingJoined(String tournamentId) {
    return checkingJoined[tournamentId] ?? false;
  }

  var isJoining = <String, bool>{}.obs;

  Future<void> joinTournament(String tournamentId) async {
    try {
      isJoining[tournamentId] = true;
      
      final response = await tournamentService.joinTournament(tournamentId);
      
      if (response.isSuccess) {
        // Update joined status after successful join
        joinedStatus[tournamentId] = true;
        Get.snackbar(
          'Thành công',
          response.message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log('Error joining tournament $tournamentId: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi tham gia tournament',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isJoining[tournamentId] = false;
    }
  }

  bool isLoadingJoin(String tournamentId) {
    return isJoining[tournamentId] ?? false;
  }

  var isLoadingToday = <String, bool>{}.obs;

  Future<void> startTournamentQuiz(String tournamentId) async {
    try {
      isLoadingToday[tournamentId] = true;
      
      // Get tournament today to get quizSetId
      final response = await tournamentService.getTournamentToday(tournamentId);
      
      if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
        final quizSetId = response.data!;
        
        // Check if already completed today
        await checkCompletedToday(tournamentId, quizSetId);
        
        if (isCompletedToday(tournamentId)) {
          Get.snackbar(
            'Thông báo',
            'Bạn đã hoàn thành bài thi hôm nay rồi!',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          isLoadingToday[tournamentId] = false;
          return;
        }
        
        // Initialize SingleModeController and start quiz
        Get.lazyPut<SingleModeController>(
          () => SingleModeController(),
        );
        final singleModeController = Get.find<SingleModeController>();
        await singleModeController.startQuiz(quizSetId);
      } else {
        Get.snackbar(
          'Lỗi',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log('Error starting tournament quiz $tournamentId: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi bắt đầu làm bài',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingToday[tournamentId] = false;
    }
  }

  // Check completed today when joined status is checked
  Future<void> checkCompletedTodayForJoinedTournament(String tournamentId) async {
    try {
      // Get tournament today to get quizSetId
      final response = await tournamentService.getTournamentToday(tournamentId);
      
      if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
        final quizSetId = response.data!;
        await checkCompletedToday(tournamentId, quizSetId);
      }
    } catch (e) {
      log('Error checking completed today for joined tournament $tournamentId: $e');
    }
  }

  bool isLoadingTodayQuiz(String tournamentId) {
    return isLoadingToday[tournamentId] ?? false;
  }

  Future<void> checkCompletedToday(String tournamentId, String quizSetId) async {
    try {
      checkingCompletedToday[tournamentId] = true;
      
      final userId = BaseCommon.instance.userId;
      if (userId.isEmpty) {
        completedToday[tournamentId] = false;
        return;
      }
      
      // Call API with filters: quizSetId, status = completed, attemptType = single
      final response = await quizHistoryService.getUserHistoryWithFilters(
        userId,
        quizSetId: quizSetId,
        status: 'completed',
        attemptType: 'single',
      );
      
      if (response.isSuccess && response.data != null) {
        // Check if any attempt has createdAt = today
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final todayEnd = todayStart.add(const Duration(days: 1));
        
        final hasCompletedToday = response.data!.any((attempt) {
          final createdAt = attempt.createdAt;
          return createdAt.isAfter(todayStart) && createdAt.isBefore(todayEnd);
        });
        
        completedToday[tournamentId] = hasCompletedToday;
      } else {
        completedToday[tournamentId] = false;
      }
    } catch (e) {
      log('Error checking completed today for tournament $tournamentId: $e');
      completedToday[tournamentId] = false;
    } finally {
      checkingCompletedToday[tournamentId] = false;
    }
  }

  bool isCompletedToday(String tournamentId) {
    return completedToday[tournamentId] ?? false;
  }

  bool isLoadingCompletedToday(String tournamentId) {
    return checkingCompletedToday[tournamentId] ?? false;
  }
}

