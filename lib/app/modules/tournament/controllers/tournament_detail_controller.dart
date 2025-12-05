import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quizkahoot/app/data/dio_interceptor.dart';
import 'package:quizkahoot/app/modules/tournament/data/tournament_api.dart';
import 'package:quizkahoot/app/modules/tournament/data/tournament_service.dart';
import 'package:quizkahoot/app/modules/tournament/models/tournament_leaderboard_model.dart';
import 'package:quizkahoot/app/modules/tournament/models/tournament_model.dart';

const baseUrl = 'https://qul-api.onrender.com/api';

class TournamentDetailController extends GetxController {
  late TournamentService tournamentService;
  
  // Observable variables
  var isLoading = false.obs;
  var leaderboard = <TournamentLeaderboardRanking>[].obs;
  var tournament = Rxn<TournamentModel>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTournamentService();
    
    // Get tournament ID from arguments
    final tournamentId = Get.arguments as String?;
    if (tournamentId != null) {
      loadTournamentLeaderboard(tournamentId);
    }
  }

  void _initializeTournamentService() {
    Dio dio = Dio();
    dio.interceptors.add(DioIntercepTorCustom());
    tournamentService = TournamentService(tournamentApi: TournamentApi(dio, baseUrl: baseUrl));
  }

  Future<void> loadTournamentLeaderboard(String tournamentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await tournamentService.getTournamentLeaderboard(tournamentId);
      if (response.isSuccess && response.data != null) {
        leaderboard.value = response.data!;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      log('Error loading tournament leaderboard: $e');
      errorMessage.value = 'Không thể tải bảng xếp hạng. Vui lòng thử lại.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshLeaderboard() async {
    final tournamentId = Get.arguments as String?;
    if (tournamentId != null) {
      await loadTournamentLeaderboard(tournamentId);
    }
  }
}

