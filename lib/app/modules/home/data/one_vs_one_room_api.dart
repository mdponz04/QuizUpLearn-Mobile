import 'package:dio/dio.dart';
import 'package:quizkahoot/app/modules/home/models/create_one_vs_one_room_request.dart';
import 'package:quizkahoot/app/modules/home/models/create_one_vs_one_room_response.dart';
import 'package:retrofit/retrofit.dart';

part 'one_vs_one_room_api.g.dart';

@RestApi()
abstract class OneVsOneRoomApi {
  factory OneVsOneRoomApi(Dio dio, {required String? baseUrl}) = _OneVsOneRoomApi;
  
  @POST('/onevsone/create')
  Future<CreateOneVsOneRoomResponse> createRoom(@Body() CreateOneVsOneRoomRequest request);
}

