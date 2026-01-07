import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/home/data/game_api.dart';
import 'package:quizkahoot/app/modules/home/models/create_game_request.dart';
import 'package:quizkahoot/app/modules/home/models/create_game_response.dart';
import 'package:quizkahoot/app/modules/home/models/validate_game_pin_response.dart';
import 'package:quizkahoot/app/modules/home/models/game_session_response.dart';

class GameService {
  GameService({required this.gameApi});
  GameApi gameApi;

  Future<BaseResponse<GameData>> createGame(CreateGameRequest request) async {
    try {
      final response = await gameApi.createGame(request);
      log("Create game response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Game created successfully',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to create game',
        );
      }
    } on DioException catch (e) {
      log("Error creating game: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while creating game',
      );
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }

  /// Validate game PIN (giống Web app)
  Future<BaseResponse<ValidateGamePinData>> validateGamePin(String gamePin) async {
    try {
      final response = await gameApi.validateGamePin(gamePin);
      log("Validate game PIN response: ${response.toString()}");
      log("Validate game PIN response type: ${response.runtimeType}");
      log("Validate game PIN response.data: ${response.data}");
      log("Validate game PIN response.data type: ${response.data?.runtimeType}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Game PIN is valid',
          data: response.data!,
        );
      } else {
        // Ưu tiên lấy message, nếu không có thì lấy error
        final message = response.message?.toString();
        final errorText = message != null && message.isNotEmpty
            ? message
            : (response.error?.toString() ?? 'Game PIN không hợp lệ');
        return BaseResponse.error(errorText);
      }
    } on DioException catch (e) {
      log("Error validating game PIN (DioException): ${e.toString()}");
      log("Error response data: ${e.response?.data}");
      log("Error response data type: ${e.response?.data?.runtimeType}");
      // Ưu tiên lấy message, nếu không có thì lấy error
      final errorData = e.response?.data;
      String? errorMessage;
      if (errorData is Map) {
        errorMessage = errorData['message']?.toString();
        if (errorMessage == null || errorMessage.isEmpty) {
          errorMessage = errorData['error']?.toString();
        }
      }
      return BaseResponse.error(
        errorMessage ?? 'An error occurred while validating game PIN',
      );
    } catch (e, stackTrace) {
      log("Unexpected error validating game PIN: ${e.toString()}");
      log("Stack trace: ${stackTrace.toString()}");
      return BaseResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Get game session (giống Web app)
  Future<BaseResponse<GameSessionData>> getGameSession(String gamePin) async {
    try {
      final response = await gameApi.getGameSession(gamePin);
      log("Get game session response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Game session retrieved successfully',
          data: response.data!,
        );
      } else {
        // Ưu tiên lấy message, nếu không có thì lấy error
        final message = response.message?.toString();
        final errorText = message != null && message.isNotEmpty
            ? message
            : (response.error?.toString() ?? 'Không thể lấy thông tin game');
        return BaseResponse.error(errorText);
      }
    } on DioException catch (e) {
      log("Error getting game session: ${e.toString()}");
      // Ưu tiên lấy message, nếu không có thì lấy error
      final errorData = e.response?.data;
      String? errorMessage;
      if (errorData is Map) {
        errorMessage = errorData['message']?.toString();
        if (errorMessage == null || errorMessage.isEmpty) {
          errorMessage = errorData['error']?.toString();
        }
      }
      return BaseResponse.error(
        errorMessage ?? 'An error occurred while getting game session',
      );
    } catch (e) {
      log("Unexpected error getting game session: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }
}

