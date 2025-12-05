import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/tournament/data/tournament_api.dart';
import 'package:quizkahoot/app/modules/tournament/models/tournament_leaderboard_model.dart';
import 'package:quizkahoot/app/modules/tournament/models/tournament_model.dart';

class TournamentService {
  TournamentService({required this.tournamentApi});
  TournamentApi tournamentApi;

  Future<BaseResponse<List<TournamentModel>>> getTournaments() async {
    try {
      // Hardcode includeDeleted = false as requested
      final response = await tournamentApi.getTournaments(false);
      log("Tournament response: ${response.toString()}");
      
      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: 'Success',
          data: response.data,
        );
      } else {
        return BaseResponse.error(
          response.message.isNotEmpty ? response.message : 'Failed to fetch tournaments',
        );
      }
    } on DioException catch (e) {
      log("Error fetching tournaments: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while fetching tournaments',
      );
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }

  Future<BaseResponse<bool>> checkJoined(String tournamentId) async {
    try {
      final response = await tournamentApi.checkJoined(tournamentId);
      log("Check joined response: ${response.toString()}");
      
      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: response.message,
          data: response.data.isJoined,
        );
      } else {
        return BaseResponse.error(
          response.message.isNotEmpty ? response.message : 'Failed to check joined status',
        );
      }
    } on DioException catch (e) {
      log("Error checking joined status: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while checking joined status',
      );
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }

  Future<BaseResponse<void>> joinTournament(String tournamentId) async {
    try {
      // Body rỗng {} như yêu cầu
      final response = await tournamentApi.joinTournament(tournamentId, {});
      log("Join tournament response: ${response.toString()}");
      
      if (response.success) {
        return BaseResponse(
          isSuccess: true,
          message: response.message.isNotEmpty ? response.message : 'Joined tournament',
          data: null,
        );
      } else {
        return BaseResponse.error(
          response.message.isNotEmpty ? response.message : 'Failed to join tournament',
        );
      }
    } on DioException catch (e) {
      log("Error joining tournament: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while joining tournament',
      );
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }

  Future<BaseResponse<String>> getTournamentToday(String tournamentId) async {
    try {
      final response = await tournamentApi.getTournamentToday(tournamentId);
      log("Get tournament today response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message ?? 'Success',
          data: response.data!.quizSetId,
        );
      } else {
        final errorMessage = response.message;
        return BaseResponse.error(
          (errorMessage != null && errorMessage.isNotEmpty) ? errorMessage : 'Failed to get tournament today',
        );
      }
    } on DioException catch (e) {
      log("Error getting tournament today: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while getting tournament today',
      );
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }

  Future<BaseResponse<List<TournamentLeaderboardRanking>>> getTournamentLeaderboard(String tournamentId) async {
    try {
      final response = await tournamentApi.getTournamentLeaderboard(tournamentId);
      log("Get tournament leaderboard response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message ?? 'Success',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message ?? 'Failed to fetch tournament leaderboard',
        );
      }
    } on DioException catch (e) {
      log("Error getting tournament leaderboard: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while fetching tournament leaderboard',
      );
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }
}

