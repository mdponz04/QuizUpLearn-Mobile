import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:quizkahoot/app/data/base_response.dart';
import 'package:quizkahoot/app/modules/home/data/one_vs_one_room_api.dart';
import 'package:quizkahoot/app/modules/home/models/create_one_vs_one_room_request.dart';
import 'package:quizkahoot/app/modules/home/models/create_one_vs_one_room_response.dart';

class OneVsOneRoomService {
  OneVsOneRoomService({required this.oneVsOneRoomApi});
  OneVsOneRoomApi oneVsOneRoomApi;

  Future<BaseResponse<OneVsOneRoomData>> createRoom(CreateOneVsOneRoomRequest request) async {
    try {
      final response = await oneVsOneRoomApi.createRoom(request);
      log("Create 1vs1 room response: ${response.toString()}");
      
      if (response.success && response.data != null) {
        return BaseResponse(
          isSuccess: true,
          message: response.message?.toString() ?? 'Room created successfully',
          data: response.data!,
        );
      } else {
        return BaseResponse.error(
          response.message?.toString() ?? 'Failed to create room',
        );
      }
    } on DioException catch (e) {
      log("Error creating 1vs1 room: ${e.toString()}");
      return BaseResponse.error(
        e.response?.data['message'] ?? 'An error occurred while creating room',
      );
    } catch (e) {
      log("Unexpected error: ${e.toString()}");
      return BaseResponse.error('An unexpected error occurred');
    }
  }
}

